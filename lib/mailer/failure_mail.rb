class FailureMail

  def initialize(record)
    @record = record
  end

  def subject
    "Integration Failure Detected for Order number: #{@record.order.number}/id:#{@record.order.id}"
  end

  def html_body
    "This message is to let you know that the order number: #{@record.order.number} id: #{@record.order.id} <br />
    failed to integrate for the first time. However, this service was able to schedule this integration at #{Time.now}.
    <b>Please, check on Abacos if the integration was successfull</b>"
  end

end