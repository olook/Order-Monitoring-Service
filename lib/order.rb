class Order < ActiveRecord::Base

 scope :from_checkpoint, lambda {|id| where("id > ?", id).limit(OrderMonitService::SERVICE_CONFIG[:max_orders_per_request]) }
 scope :delayed, lambda {|time| where("created_at <= '#{Time.now - time}'")}
end
