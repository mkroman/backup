# encoding: utf-8

module Backup
  class Node
    DefaultPath = "/"
    DefaultUser = "root"

    attr_accessor :name, :cache, :options

    def initialize name, options = {}
      @name = name
      @options = options
    end

    def connect &block
      address  = @options["address"]
      username = @options["user"] or DefaultUser

      @session ||= Net::SSH.start address, username, &block
    end

    def zip_command
      path    = @options["path"] || DefaultPath
      exclude = @options["exclude"] || %w{}

      flags = exclude.map{|path| "--exclude=#{path.shellescape}" }.join " "

      %{tar cf - #{path} --lzma #{flags}}
    end

    def log *messages
      messages.each do |message|
        puts "#{Time.now.strftime '%H:%M:%S'} \e[1m#{name}:\e[0;0m #{message}"
      end
    end
  end
end