class Order < ActiveRecord::Base

 scope :from_checkpoint, lambda {|id| where("id > ?", id).limit(OrderMonitService::SERVICE_CONFIG[:max_orders_per_request]) }

 def delayed time
  from_checkpoint.map(&:created_at).select{|d| d <= (Time.zone.now - time)}
 end
end