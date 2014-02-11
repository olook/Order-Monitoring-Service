class EnqueueingService

    include Observable

    attr_reader :checkpoint, :integration_records
    
    def initialize(db_conf, max_attempts)
      @db_conf, @max_attempts = db_conf, max_attempts
      @checkpoint = Checkpoint.instance
      connect
      @integration_records = []
    end

    def load_integration_records
      integration_records << load_failed_integration_records + load_new_records
      integration_records.flatten!
    end

    def load_failed_integration_records
      checkpoint.integration_records.clone.keep_if { |ir| 
        (ir.status == "FAILED" && ir.num_of_attempts.to_i <= @max_attempts )
      }
    end

    def load_new_records
      connect
      Order.from_checkpoint(@checkpoint.head).delayed(1800).collect { |order| 
        OrderIntegrationRecord.new(nil,nil,nil,order,nil,0)
      }    
    end

    def process
      reload!
      puts 'loading records'
      load_integration_records
      puts 'records loaded'
      if !integration_records.empty?
        integration_records.each do |record|
          puts "analysing record #{record.order.number}"
          changed
          notify_observers(record)
          puts "finished order"
        end
      end
    end

    private

    def reload!
      integration_records.clear
      @checkpoint.reload!
    end

    def connect
      begin
        ActiveRecord::Base.establish_connection(@db_conf)
      rescue Exception => e
        puts "Problem connecting to the database: #{e.message}"
      end
    end

end
