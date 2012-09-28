class AlertMailer

    def initialize(email_config)
      @config = email_config
      Pony.options = {:via => :smtp, :via_options => @config[:smtp]}
    end

    def update(email)
      Pony.mail(:to => @config[:subscribers], :subject => email.subject,:body => email.body)
    end

end