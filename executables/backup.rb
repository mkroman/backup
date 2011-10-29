#!/usr/bin/env ruby
# encoding: utf-8

$:.unshift File.dirname(__FILE__) + '/../library'
require 'backup'

manager = Backup::Manager.new

puts "=> Backup v#{Backup::Version}"

manager.commence_backup!
manager.save_cache
