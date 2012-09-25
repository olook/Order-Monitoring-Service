Feature: Integrate order with Abacos
  In order to integrate an order with abacos, the system must be able 
  to cope with many different failure scenarios

  Scenario: Abacos is down
    Given that abacos is down
    When the system tries to connect to the WS
    Then it should timeout
    And reschedule the next attempt for a future time
    And send notification to subscribers
    And mark order with a fail status


  Scenario: Abacos is down after the second attempt
    Given that abacos is still down
    When the system tries to send the order again
    Then it should timeout
    And reschedule the last attempt to a second future time
    And send notification to subscribers
    And mark order with a fail status

  Scenario: Abacos is down after the third attempt
    Given that Abacos is still down after the second attempt
    When the system tries to send the order again
    Then it should timeout
    And permanently flag the order as failed
    And send notification to subscribers

  Scenario: Abacos returns an exception
    Given that abacos is running
    When the system sends the order and abacos return an exception
    Then it should log the attempt with a fail
    And update move the HEAD
    And send notification to subscribers
    But it should not retry