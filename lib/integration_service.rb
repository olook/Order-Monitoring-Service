class IntegrationService

  STATUS = {:success => "SUCCESS", :failed => "FAILED"}

  include Observable
  include Connectable

  def initialize(integration_server_config, downtime_wait)
    @config, @downtime_wait = integration_server_config, downtime_wait
    @checkpoint = Checkpoint.instance
  end

  def update(record)
    begin
      abacos_response = Abacos::OrderAPI.order_exists?(record.order.number)
      # TODO - Code Refactor (abacos_response)
      if abacos_response.values[0] == true
        if abacos_response.keys[0] == "tspeeEmAndamento" && record.order.state == "authorized"
          integration_record = OrderIntegrationRecordBuilder.build(record, STATUS[:failed], "PAYMENT_PENDING")
          changed
          notify_observers(PendingPaymentMail.new(record))
        else
          integration_record = OrderIntegrationRecordBuilder.build(record, STATUS[:success], "OK")
        end
      else
        integration_record = OrderIntegrationRecordBuilder.build(record, STATUS[:failed], "NOT_FOUND")
        changed
        notify_observers(FailureMail.new(record))
        connect(@config[:host], @config[:username], @config[:port], @config[:rails_root])
        insert_order(record.order.number)
      end

    rescue Errno::ETIMEDOUT => error
      changed
      notify_observers(ErrorMail.new("Local internet access or Abacos is down: #{error.message}"))
      sleep(@downtime_wait)
    rescue Wasabi::Resolver::HTTPError => error
      changed
      notify_observers(ErrorMail.new("Error while communicating with Abacos. HTTP error code: #{error.message.code}"))
      sleep(@downtime_wait)
    rescue Exception => error
      changed
      puts "#{error.message}"
      notify_observers(ErrorMail.new("Critical exception: #{error.class} #{error.message}"))
    ensure
        if !integration_record.nil? 
          write_to_checkpoint_file(integration_record)
        end
    end
  end

  private

  def write_to_checkpoint_file(integration_record)
    @checkpoint.open_atomically(@checkpoint.file_path) do |new_file|
      new_file.puts @checkpoint.write_buffer(integration_record)
    end
  end
  

  end