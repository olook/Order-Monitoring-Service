require 'active_record'


class Order < ActiveRecord::Base

 scope :from_checkpoint, lambda {|id| where('id > ?', id).limit(5) }

end