require 'observer'
require 'pony'
require 'singleton'
require 'rye'
require 'daemons'
require 'fileutils'
require 'tempfile'
require 'active_record'

Dir[(File.dirname(__FILE__)+"/lib/**/")].each{|load_path| $: << load_path}
require 'connectable'
Dir[File.join("lib", "**", "*.rb")].each {|file| require File.basename(file) }

extend OrderMonitService

load_system_configuration

Daemons.run('main.rb',PROCESS_CONFIG)
