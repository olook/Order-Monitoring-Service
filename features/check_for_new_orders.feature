Feature: Check for new orders
  In order to process new orders, the system must check within a period of time, if there is 
  new order to be processed

  Scenario: There are no new orders
    Given an order id "123"
    When the system has processed the order already
    Then the system should keep its state idle
    And check for new orders within a period of time

  Scenario: There are new orders
    Given an order id "123"
    When the system has not processed the order yet
    Then the system should grab an order
    And set it state to busy
    And check for new orders within a period of time