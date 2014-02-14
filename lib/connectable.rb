module Connectable

  def connect(host, username, port, rails_root)
    puts "creating connection to integration server #{[host, username, port, rails_root]}"
    @rbox = Rye::Box.new(host,:user => username, :port => port, :safe => false, :keys => ["/home/ubuntu/.ssh/gsg-keypair"]})
    @rbox[rails_root]
  end

  def insert_order(number)
    puts "inserting order #{number}"
    @rbox.execute "sudo -u deploy nohup bundle exec rake order_integration_service:insert_order[#{number}] RAILS_ENV=production > /dev/null 2>&1 & "
    puts "order #{number} inserted"
  end

  def confirm_payment(number)
    @rbox.execute "sudo -u deploy nohup bundle exec rake order_integration_service:confirm_payment[#{number}] RAILS_ENV=production > /dev/null 2>&1 &"
  end

end
