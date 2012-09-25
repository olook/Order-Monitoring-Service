module AbacosIntegrationMonitor
  class OrderProcessingService

    include Observable

    attr_reader :checkpoint, :integration_records
    
    def initialize
      @checkpoint = Checkpoint.instance
      @integration_records = []
    end

    def load_integration_records
      integration_records << load_failed_integration_records + load_new_records
      integration_records.flatten!
    end

    def load_failed_integration_records
      checkpoint.integration_records.clone.keep_if { |ir| ir.status == "FAILED"}
    end

    def load_new_records
      Order.from_checkpoint(@checkpoint.head).collect { |order| OrderIntegrationRecord.new(nil,nil,nil,order,nil)}    
    end

    def process
      reload!
      load_integration_records
      if !integration_records.empty?
        integration_records.each do |order|
          changed
          notify_observers(order)
        end
      end
    end

    private

    def reload!
      integration_records.clear
      @checkpoint.reload!
    end

  end
end