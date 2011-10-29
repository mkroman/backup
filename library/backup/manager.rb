# encoding: utf-8

module Backup
  class Manager
    DefaultFrequency = 86400

    def initialize
      config = YAML.load_file Backup.root "configuration", "nodes.yml"
      @nodes = config.map{|name, options| Node.new name, options }

      read_cache
    end

    def read_cache
      path = Backup.root ".history.yml"

      if File.exists? path
        cache = YAML.load_file path

        @nodes.each{|node| node.cache = (cache[node.name] || {}) }
      else
        @nodes.each{|node| node.cache = {} }
      end
    end

    def save_cache
      path = Backup.root ".history.yml"
      cache = {}

      @nodes.each{|node| cache[node.name] = node.cache }

      File.open path, "w+" do |file|
        YAML.dump cache, file
      end
    end

    def commence_backup!
      nodes = selected_nodes

      if nodes.any?
        puts "The following nodes are being backed up: " + nodes.map(&:name).join(', ')
      else
        puts "Nothing to do"
      end

      nodes.each do |node|
        node.log "Connecting"

        node.connect do |session|
          node.log "Connection established"

          path = Pathname.new Backup.root "archives", node.name
          archive = path.join "#{timestamp}.tar.xz"

          unless path.exist?
            node.log "Creating local directories"
            path.mkpath
          end

          node.log "Piping the archive"

          size = 0
          file = File.open archive, "w+"

          session.exec! node.zip_command do |channel, stream, data|
            if stream == :stdout
              size += data.bytesize
              file.write data
            end
          end

          file.close

          node.cache[:last_updated] = Time.now.to_i

          node.log "Transfer complete"
          node.log "A total of #{size} bytes was received"
          node.log "Closing channel"

          link = path.join "latest.tar.xz"

          if link.symlink?
            node.log "Updating symbolic link"

            File.unlink link
          else
            node.log "Creating symbolic link"
          end

          File.symlink archive.basename, archive.parent.join("latest.tar.xz")
        end
      end
    end

  private

    def timestamp
      Time.now.strftime "%d-%m-%y_%H:%M:%S"
    end

    def selected_nodes
      @nodes.select do |node|
        frequency    = node.options["frequency"] || DefaultFrequency
        last_updated = node.cache[:last_updated] || Time.now.to_i - frequency - 1

        last_updated < Time.now.to_i - frequency
      end
    end
  end
end
