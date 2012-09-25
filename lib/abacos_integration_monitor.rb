class Hash
  def recursive_symbolize_keys!
    symbolize_keys!
    # symbolize each hash in .values
    values.each{|h| h.recursive_symbolize_keys! if h.is_a?(Hash) }
    # symbolize each hash inside an array in .values
    values.select{|v| v.is_a?(Array) }.flatten.each{|h| h.recursive_symbolize_keys! if h.is_a?(Hash) }
    self
  end
end

module AbacosIntegrationMonitor

  CONFIG = YAML.load_file(File.dirname(__FILE__) + '/../' + 'config/config.yml').recursive_symbolize_keys!
  
  ActiveRecord::Base.establish_connection(CONFIG[:database])

end