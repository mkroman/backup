#!/usr/bin/env ruby
# encoding: utf-8

$:.unshift File.dirname(__FILE__) + '/../library'
require 'cloud'

manager = Cloud::Manager.new

puts "=> Cloud v#{Cloud::Version}"
manager.commence_backup!