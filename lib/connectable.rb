module Connectable

  def connect(host, username, port, rails_root)
    puts "creating connection to integration server #{[host, username, port, rails_root]}"
    @rbox = Rye::Box.new(host,:user => username, :port => port, :safe => false)
    @rbox[rails_root]
  end

  def insert_order(number)
    puts "inserting order #{number}"
    @rbox.execute "nohup bundle exec rake order_integration_service:insert_order[#{number}] > /dev/null 2>&1 &"
    puts "order #{number} inserted"
  end

  def confirm_payment(number)
    @rbox.execute "nohup bundle exec rake order_integration_service:confirm_payment[#{number}] > /dev/null 2>&1 &"
  end

end
