require 'observer'
require 'pony'
require 'singleton'
require 'rye'
require 'daemons'
require 'fileutils'
require 'tempfile'
require 'ruby-debug'

Dir[(File.dirname(__FILE__)+"/lib/**/")].each{|load_path| $: << load_path}
Dir[File.join("lib", "**", "*.rb")].each {|file| require File.basename(file) }

extend AbacosIntegrationMonitor

APP_CONFIG = CONFIG[:general]
PROCESS_CONFIG = APP_CONFIG[:process]

Daemons.run('app.rb',PROCESS_CONFIG)