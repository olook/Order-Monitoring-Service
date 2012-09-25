require 'fileutils'
require 'tempfile'

module AbacosIntegrationMonitor
  class Checkpoint
    
    include Singleton

    attr_reader :integration_records, :filename

    def initialize(filename='checkpoint')
      @filename, @integration_records, @pointer = filename, [], {}
    end

    def reload!
      @integration_records.clear
      @pointer.clear
      parse_file
    end

    def parse_file
      file = File.open(File.dirname(__FILE__)+"/"+@filename, 'r').readlines
      file.each_with_index do |line, i|
        integration_records << OrderIntegrationRecord.new(*line.split(" "))
        @pointer[i] = line.split(" ")[3] if line.include?("^HEAD")
      end
    end

    def head
      @pointer.values[0]
    end

    def index
      @pointer.keys[0]
    end

    def write_buffer(record)
      if !record.new? && record.id != "^HEAD"
        integration_records[record.id.to_i] = record
      elsif !record.new? && record.id == "^HEAD"
        integration_records[integration_records.size-1] = record
      else
        integration_records.last.id = (integration_records.size-1).to_s
        integration_records << record    
      end
      integration_records
    end
    
    # Using the native atomic move function from *nix
    # this method prevents the system from performing partial writes
    # it will overwrite with a complete replacement or not at all

    def open_atomically(path)
      result, temp_path = nil, nil
      Tempfile.open("#{$0}-#{path.hash}") do |f|
        result = yield f
        temp_path = f.path
      end
      FileUtils.move(temp_path, path)
      result
    end
  end
end