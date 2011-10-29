# encoding: utf-8

require 'yaml'
require 'net/ssh'
require 'shellwords'
require 'bundler/setup'

require 'backup/node'
require 'backup/beacon'
require 'backup/manager'

module Backup
  Version = "0.1"

  def self.root *paths
    File.join File.dirname($0), *paths
  end
end
