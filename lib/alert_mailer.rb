class AlertMailer

    def initialize(email_config)
      puts "AlertMailer inicializado: #{email_config}"
      @config = email_config
      Pony.options = {:via => :smtp, :via_options => @config[:smtp]}
    end

    def update(email)
      puts "email para: #{@config[:subscribers]}"
      puts "subject: #{email.subject}"
      puts "body: #{email.html_body}"
      Pony.mail(:to => @config[:subscribers], :subject => email.subject,:html_body => email.html_body)
      puts "enviado"
    end

end