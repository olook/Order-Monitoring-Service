Introduction
============

This monitoring service aims to periodically check if orders from the **Front** were successfully integrated with **Abacos**. 

Some important design decisions:

- The service actively checks all orders in the database since the last checkpoint(^HEAD). It does not take into consideration the variable "status" of order. In this way the service can always assume the worst scenario (or the failure scenarios). They could pottentially be happening now or could  be introduced in the future by changes on the front
- There should exist only one authoritative WS integration point (the app servers or resque servers). The reason for this decision is that the logic that builds XML messages, has a great chance to change in the future. Therefore to avoid bringing all this code to the service side, and hence getting code duplication and dependency, we use Rye to connect to a remote machine and run a rake task on a remote authoritative integration node.
- To minimize complexity, the service is single threaded. At a specified given period, the service retries to integrate failed orders, checks for new orders, and atomically write each operation to a "checkpoint" file.
- The checkpoint file is a lightweight alternative for maintaining the service state, as a DBMS would be an overkill

Dependencies
============

The only external dependency from this service is the rake task _insert\_order_ and _confirm\_payment_. As commented above, the monitoring service doesn't care if the internal logic of how to insert an order and how to confirm a paytment changes, as long as both still implement `Abacos::InsertOrder.perform(order_number)` and `Abacos::ConfirmPayment.perform(order_number)`


Setup
============

First run `bundle install`

Then set up your configurations on config. The service.yml and process.yml are explained below:

The _service.yml_ file

```service
running_cycle: 120 #seconds, the same time used to verify new orders
max_attempts: 4 # maximum number of attempts to integration in case of failure
max_orders_per_request: 5 # maximum number of new order returned per cycle
downtime_wait: 30 # seconds to wait before reconnecting to Abacos, in case of downtime
```
The _process.yml_ file

```process
app_name: "Order Monit Service"
ontop: true # if true the process is not sent to the background
log_output: true # writes an output file, you may want to use this option for a background process
backtrace: true
```
The _integration\_server.yml_  file

```integration_server
host: "homolog.olook.com.br"
port: 13630
username: "root"
rails_root: "/srv/olook/current
```

The authentication with the *integration\_server* happens through the *public key* `~./ssh/id_rsa.pub` of the machine
running the service

There is an important file  `data/checkpoint` which keeps the state of all processed orders and the current position of the `^HEAD`.

```checkpoint
0 01/10/2012-03:34:15 01/10/2012-03:45:22 72025 SUCCESS OK 0
1 01/10/2012-11:18:48 01/10/2012-11:25:03 72026 FAILED PAYMENT_PENDING 5
2 01/10/2012-11:18:53 01/10/2012-11:18:53 72032 SUCCESS OK 1
3 01/10/2012-11:18:55 01/10/2012-11:18:55 72045 SUCCESS OK 1
4 01/10/2012-11:18:57 01/10/2012-11:18:57 72049 SUCCESS OK 1
5 01/10/2012-11:18:59 01/10/2012-11:18:59 72051 SUCCESS OK 1
6 01/10/2012-11:23:45 01/10/2012-11:23:45 72054 SUCCESS OK 1
7 01/10/2012-11:23:47 01/10/2012-11:23:47 72055 SUCCESS OK 1
8 01/10/2012-11:23:48 01/10/2012-11:23:48 72064 SUCCESS OK 1
9 01/10/2012-11:23:50 01/10/2012-11:23:50 72065 SUCCESS OK 1
^HEAD 26/09/2012-01:42:13 26/09/2012-01:42:13 72066 FAILED 1
```
This file is separated by spaces. Column1 represents the _index_, Column2 the _created\_at timestamp_, Column3 the _updated\_at timestamp_, Column4 the _order id_ (not the order number), Column5 the current _status_, Column6 the _number of attempts_ . Please initialize your file with the ^HEAD pointing to the id you want to start checking(just take the last order if from the database):

```checkpointsample
^HEAD [timestamp] [timestamp] [starting order id] [current status] [status reason][0] 
```

After that you should avoid modifying the _checkpoint_ file. This file is intended to be written only for the first time in order to set the initial state.

Running the app
============

To start the service run `ruby order_monit_service.rb start` 

After starting the service a .pid file is created on the root directory. This .pid file holds the PID number of the process.

To stop the service run `ruby order_monit_service.rb stop`

