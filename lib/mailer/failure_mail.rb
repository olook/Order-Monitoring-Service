class FailureMail

  def initialize(record)
    @record = record
  end

  def subject
    "Integration Failure Detected for Order number: #{@record.order.number}/id:#{@record.order.id}"
  end

  def body
    "This message is to let you know that the order number: #{@record.order.number} id: #{@record.order.id} 
    was not integrated at the first time.However, this service detected it and this order was sent for integration 
    at #{Time.now}.Please, check on Abacos if the integration was successfull"
  end

end