Introduction
============

This monitoring service aims to periodically check if orders from the **Front** were successfully integrated with **Abacos**. 

Some important design decisions:

- The service actively checks all orders in the database since the last checkpoint(^HEAD). It does not take into consideration the variable "status" of order. In this way the service can always assume the worst scenario (or the failure scenarios). They could pottentially be happening now or could  be introduced in the future by changes on the front
- There should exist only one authoritative WS integration point (the app servers or resque servers). The reason for this decision is that the logic that builds XML messages, has a great chance to change in the future. Therefore to avoid bringing all this code to the service side, and hence getting code duplication and dependency, we use Rye to connect to a remote machine and run a rake task on a remote authoritative integration node.
- To minimize complexity, the service is single threaded. At a specified given period, the service retries to integrate failed orders, checks for new orders, and atomically write each operation to a "checkpoint" file.
- The checkpoint file is a lightweight alternative for maintaining the service state, as a DBMS would be an overkill

Dependecies
============

The only external dependency from this service is the rake task _insert\_order_ and _confirm\_payment_. As commented above, the monitoring service doesn't care if the internal logic of how to insert an order and how to confirm a paytment changes, as long as both still implement `Abacos::InsertOrder.perform(order\_number)` and `Abacos::ConfirmPayment.perform(order\_number)`


Setup
============

First run `bundle install`

Then set up your configurations on config/config.yml as below:

```config
general:
  process:
    app_name: "Order Monit Service"
    ontop: false # if true the process is not sent to the background
    log_output: true # writes an output file, good when running as a background process
    backtrace: true
  running_cycle_frequency: 120 # seconds, the same time used to verify new orders
  number_of_integration_retries: 2 # number of times that the system should retry when facing a failure

  integration_server:
  host: "homolog.olook.com.br"
  port: 13630
  username: "felipe"
  password: "mypass"
  rails_root: "/srv/olook/current"
```
It is not necessary to provide a password, if the *integration\_server* has the client's *public key* id\_rsa.pub

Running the app
============

To start the service run `ruby order_monit_service.rb start` 

After starting the service a .pid file is created on the root directory. This .pid file holds the PID number of the process.

To stop the service run `ruby order_monit_service.rb stop`

