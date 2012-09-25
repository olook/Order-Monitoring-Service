require 'active_record'


class Order < ActiveRecord::Base

 scope :from_checkpoint, lambda {|id| where('id > ? AND id < 520', id) }

end