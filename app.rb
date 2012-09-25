
order_processing_service = AbacosIntegrationMonitor::OrderProcessingService.new
integration_service = AbacosIntegrationMonitor::OrderIntegrationService.new
order_processing_service.add_observer(integration_service)
integration_service.add_observer(AbacosIntegrationMonitor::AlertMailer.new)
loop {
  order_processing_service.process
  sleep(APP_CONFIG[:running_cycle_frequency])
}




# config = {
#    :name => 'SampleBot',
#    :jabber_id => 'olook@jabb3r.de',
#    :password  => 'secret',
#    :is_public => true
#  }

# Thread.new{
#     bot = Jabber::Bot.new(config)
#    bot.add_command(
#   :syntax      => 'head',
#   :description => 'Produce a random number from 0 to 10',
#   :is_public => true,
#   :regex       => /^head$/
# ) { read_files }
#     bot.connect
#   }

# def read_files
# f = File.open(File.dirname(__FILE__)+"/lib/checkpoint")
# f.readlines
# end
