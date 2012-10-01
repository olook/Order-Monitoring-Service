class ErrorMail

  extend OrderMonitService
  
  def initialize(message, system_conf=nil)
    @message, @system_conf = message, system_conf
  end

  def subject
    "An error occurred: #{@message}"
  end

  def html_body
    "There is a problem with the order integration service: #{@message}"
  end

end