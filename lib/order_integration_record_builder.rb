class OrderIntegrationRecordBuilder

  def self.build(integration_record, status)
    if integration_record.new?
      integration_record.id = "^HEAD"
      integration_record.created_at = Time.now.strftime("%d/%m/%Y-%H:%M:%S")
      integration_record.updated_at = Time.now.strftime("%d/%m/%Y-%H:%M:%S")
      integration_record.status = status
    else
      integration_record.updated_at = Time.now.strftime("%d/%m/%Y-%H:%M:%S")
      integration_record.status = status
    end
    integration_record
  end

end