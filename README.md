Introduction
============

This is a monitoring service which aims to periodically check if all orders were successfully integrated with Abacos. 


Some important design decisions:

- The service actively checks all orders in the database since the last checkpoint(^HEAD). In this way the service can always assume the worst scenario (failure scenario) that could be pottentially happening now or that could be introduced in the future
- There should be only one authoritative WS integration point (the app servers or resque servers), which suffers from constant evolution and business logic changes. Therefore to avoid bringing all this code here, and get code duplication, we use Rye to connect to a remote machine and run a rake task on a remote authoritative integration node.
- To minimize complexity, the app is single threaded. At a specified given period, the app retries to integrate failed orders, checks for new orders, and atomically write each operation to a "checkpoint" file.
- The checkpoint file is a lightweight alternative for maintaining the app state . Using a DBMS would introduce an unnecessary overhead


Setup
============

- Run `bundle install`
- Then set up your configurations on config/config.yml
```config
general:
  process:
    app_name: "Order Monit Service"
    ontop: false # if true the process is not sent to the background
    log_output: true # writes an output file, good option for a background process
    backtrace: true
  running_cycle_frequency: 120 #seconds, the same time used to verify new orders
  number_of_integration_retries: 2

  integration_server:
  host: "homolog.olook.com.br"
  port: 13630
  username: "felipe"
  password: "mypass"
  rails_root: "/srv/olook/current"
```

app_name Gives a friendly name to the app.
ontop when true the process is not send to the background and outputs are sent to $stdout
log_ouput

The communication with the integration server is triggered in case of a failed order integration. The app first checks if an order exist on Abacos. In this case, the app contacts the server and schedules either a insert_order or confirm_payment through a rake task.
It is not necessary to provide a password, if the integration_server has the client's public key id_rsa.pub

Running the app
============

To start the service run `ruby order_monit_service.rb start`  
To stop the service run `ruby order_monit_service.rb stop`

