# encoding: utf-8

module Cloud
  class Node
    DefaultPath = "/"
    DefaultUser = "root"

    attr_accessor :name, :options

    def initialize name, options = {}
      @name = name
      @options = options
    end

    def connect &block
      address  = @options[:address]
      username = @options[:user] or DefaultUser

      @session ||= Net::SSH.start address, username, &block
    end
  end
end