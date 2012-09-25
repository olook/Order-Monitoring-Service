class OrderIntegrationRecord

  attr_accessor :id, :created_at, :updated_at, :order, :status

  def initialize(id, created_at, updated_at, order, status)
    @id, @created_at, @updated_at, @status = id, created_at, updated_at, status
    @order = order.instance_of?(Order) ? order : Order.find(order)
    new_record?(@id)
  end

  def new?
    @record_state
  end

  def to_s
    "#{id} #{created_at} #{updated_at} #{order.id} #{status}"
  end

  private

  def new_record?(id)
   @record_state = @id == nil ? true : false
  end

end