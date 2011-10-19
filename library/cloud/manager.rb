# encoding: utf-8

module Cloud
  class Manager
    def initialize
      nodes = YAML.load_file "/home/mk/Projects/Cloud/configuration/nodes.yml"
      @nodes = nodes.map{|name, options| Node.new name, options }
    end

    def commence_backup!
      @nodes.each do |node|
        file = File.open "#{node.name}.tar.bz2", "w+"

        node.ssh!.exec! "tar cjf - /home/mk/apps/" do |channel, stream, data|
          file.write data if stream == :stdout
        end
      end
    end
  end
end