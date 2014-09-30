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
      puts 'loading new records'
      new_records = load_new_records
      puts 'loading failed records'
      faileds = load_failed_integration_records

      puts 'records loaded'
      integration_records << faileds + new_records
      integration_records.flatten!
    end

    def load_failed_integration_records
      faileds = checkpoint.integration_records.clone.keep_if { |ir| 
        (ir.status == "FAILED" && ir.num_of_attempts.to_i <= @max_attempts )
      }
      puts "faileds: #{faileds.size}"
      faileds
    end

    def load_new_records
      connect
      orders = Order.delayed(1800).collect { |order| 
        OrderIntegrationRecord.new(nil,nil,nil,order,nil,0)
      }    
      puts "Loaded new records #{orders.size}"
      orders
    end

    def process
	puts 'reloading...'
      reload!
	puts 'reloaded'

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
	puts 'cleaning integration records'
      integration_records.clear
	puts 'reloading checkpoint'
      @checkpoint.reload!
    end

    def connect
	puts 'connecting to database'
      begin
        ActiveRecord::Base.establish_connection(@db_conf)
      rescue Exception => e
        puts "Problem connecting to the database: #{e.message}"
      end
    end

end
