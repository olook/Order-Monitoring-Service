class OrderIntegrationRecord

  attr_accessor :id, :created_at, :updated_at, :order, :status, :num_of_attempts

  def initialize(id, created_at, updated_at, order, status, num_of_attempts=0)
    @id, @created_at, @updated_at, @status, @num_of_attempts = id, created_at, updated_at, status, num_of_attempts
    @order = order.instance_of?(Order) ? order : Order.find(order)
    new_record?(@id)
  end

  def new?
    @record_state
  end

  def to_s
    "#{id} #{created_at} #{updated_at} #{order.id} #{status} #{num_of_attempts}"
  end

  private

  def new_record?(id)
   @record_state = @id == nil ? true : false
  end

end