

queueing_service = EnqueueingService.new(DATABASE_CONFIG, SERVICE_CONFIG[:max_attempts])
integration_service = IntegrationService.new(INTEGRATION_SERVER_CONFIG,SERVICE_CONFIG[:downtime_wait])
queueing_service.add_observer(integration_service)
integration_service.add_observer(AlertMailer.new(EMAIL_CONFIG))
loop {
  queueing_service.process
  puts "Waiting..."
  sleep(SERVICE_CONFIG[:running_cycle])
  puts "Processing..."
}