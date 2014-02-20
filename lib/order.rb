class Order < ActiveRecord::Base

 scope :from_checkpoint, lambda {|id| where("id > ?", id).limit(OrderMonitService::SERVICE_CONFIG[:max_orders_per_request]) }

 def self.delayed time
  date = Time.now - time
  puts "Data limite: #{date}"
  from_checkpoint(Checkpoint.instance.head).select{|order| order.created_at <= date}
 end
end