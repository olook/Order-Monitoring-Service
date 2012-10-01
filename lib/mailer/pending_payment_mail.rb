class PendingPaymentMail

  extend OrderMonitService
  
  def initialize(record)
    @record = record
  end

  def subject
    "Pending payment confirmation for order number: #{@record.order.number} id: #{@record.order.id}"
  end

  def html_body
    "This message is to let you know that Abacos has not yet received a payment confirmation for order: #{@record.order.number}
    <br />
    <b>Please confirm this payment on the admin interface.</b>"
  end

end