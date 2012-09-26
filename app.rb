
order_processing_service = AbacosIntegrationMonitor::OrderProcessingService.new
integration_service = AbacosIntegrationMonitor::OrderIntegrationService.new
order_processing_service.add_observer(integration_service)
integration_service.add_observer(AbacosIntegrationMonitor::AlertMailer.new)
loop {
  order_processing_service.process
  sleep(APP_CONFIG[:running_cycle_frequency])
}