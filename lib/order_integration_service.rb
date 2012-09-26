module AbacosIntegrationMonitor
  class OrderIntegrationService

    INTEGRATION_SRV_CONFIG = CONFIG[:integration_server]

    ALERT_TYPE = {:failure => "Integration Failed",:error => "Exception"}

    STATUS = {:success => "SUCCESS", :failed => "FAILED"}

    include Observable

    def initialize 
      @checkpoint = Checkpoint.instance
    end

    def lazy_initialize
      @rbox = Rye::Box.new(INTEGRATION_SRV_CONFIG[:host], :user => INTEGRATION_SRV_CONFIG[:username], 
      :password => INTEGRATION_SRV_CONFIG[:password], :port => INTEGRATION_SRV_CONFIG[:port], :safe => false)
      @rbox[INTEGRATION_SRV_CONFIG[:rails_root]]
    end

    def update(record)
      integration_record = nil
      order = record.order
      begin
        if Abacos::OrderAPI.order_exists?(order.number)
          integration_record = OrderIntegrationRecordBuilder.build(record, STATUS[:success])
        else
          changed
          lazy_initialize
          notify_observers(ALERT_TYPE[:failure], record)
          integration_record = OrderIntegrationRecordBuilder.build(record, STATUS[:failed])
          insert_order(order.number)
          confirm_payment(order.number) if order.state == "authorized"
        end
      rescue Errno::ETIMEDOUT => error
        puts "Local internet access or Abacos is down: #{error.message}"
      rescue Wasabi::Resolver::HTTPError => error
        puts "Error while communicating with Abacos server! Code: #{error.message.code}"
      rescue Exception => error
        puts "Critical exception: #{error.message}"
      ensure
        if !integration_record.nil? 
          @checkpoint.open_atomically(@checkpoint.file_path) do |new_file|
            new_file.puts @checkpoint.write_buffer(integration_record)
          end
        end
      end
    end

    # Using the Secure Shell Protocol to integrate orders  
    # this way the integration WS is not bound to the app, and only to the
    # rake process

    def insert_order(number)
      @rbox.execute "nohup bundle exec rake order_integration_service:insert_order[#{number}] > /dev/null 2>&1 &"
    end

    def confirm_payment(number)
      @rbox.execute "nohup bundle exec rake order_integration_service:confirm_payment[#{number}] > /dev/null 2>&1 &"
    end
  

  end
end