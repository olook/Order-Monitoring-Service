class IntegrationService

    STATUS = {:success => "SUCCESS", :failed => "FAILED"}

    include Observable

    def initialize(integration_server_config, downtime_wait)
      @config, @downtime_wait = integration_server_config, downtime_wait
      @checkpoint = Checkpoint.instance
    end

    def lazy_initialize
      @rbox = Rye::Box.new(@config[:host],:user => @config[:username], :port => @config[:port], :safe => false)
      @rbox[@config[:rails_root]]
    end

    def update(record)
      begin
        if Abacos::OrderAPI.order_exists?(record.order.number)
          status = STATUS[:success]
        else
          status = STATUS[:failed]
          changed
          lazy_initialize
          notify_observers(FailureMail.new(record))
          insert_order(record.order.number)
          confirm_payment(record.order.number) if record.order.state == "authorized"
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
        if !status.nil? 
          @checkpoint.open_atomically(@checkpoint.file_path) do |new_file|
            new_file.puts @checkpoint.write_buffer(OrderIntegrationRecordBuilder.build(record, status))
          end
        end
      end
    end

    def insert_order(number)
      @rbox.execute "nohup bundle exec rake order_integration_service:insert_order[#{number}] > /dev/null 2>&1 &"
    end

    def confirm_payment(number)
      @rbox.execute "nohup bundle exec rake order_integration_service:confirm_payment[#{number}] > /dev/null 2>&1 &"
    end
  

  end