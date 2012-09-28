module OrderMonitService

  def load_system_configuration
    files = Dir[File.join(File.dirname(__FILE__), "..", "config", "*.yml")]
    files.each do |file|
      OrderMonitService.const_set("#{File.basename(file, '.yml').upcase}_CONFIG", YAML.load_file(file).recursive_symbolize_keys!)
    end
  end

end