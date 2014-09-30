class Order < ActiveRecord::Base


 scope :from_checkpoint, lambda {|id| where("id > ?", id).limit(50) }
 #scope :from_checkpoint, lambda {|id| where("id > ?", id).limit(OrderMonitService::SERVICE_CONFIG[:max_orders_per_request]) }
 
def self.delayed time
  date = Time.now - time
  puts "Data limite: #{date}"
  #orders = from_checkpoint(Checkpoint.instance.head).where('created_at <= DATE_SUB(now(), INTERVAL 1800 SECOND)')
  orders = from_checkpoint(Checkpoint.instance.head).where('created_at <= DATE_SUB(now(), INTERVAL 1800 SECOND)')
  puts orders.size
  orders
 end
end
