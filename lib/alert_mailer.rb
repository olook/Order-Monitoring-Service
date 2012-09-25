module AbacosIntegrationMonitor
  class AlertMailer

    MAILER_CONFIG = CONFIG[:email]

    def initialize
      Pony.options = {:via => :smtp, :via_options => MAILER_CONFIG[:smtp]}
    end

    def update(alert, order)
      Pony.mail(:to => MAILER_CONFIG[:subscribers], :subject => subject(order),:body => body(order))
    end

    def body(order)
      "This message is to let you know that the order number: #{order.order.number}/id: #{order.order.id} 
       was not integrated at the first place.However, this service detected and a attempt for integration 
       was sent at #{Time.now}.Please, check on Abacos if this integration was successfull"
    end

    def subject(order)
      "Integration Failure Detected for Order number: #{order.order.number}/id:#{order.order.id}"
    end

  end
end