Feature: Check order integration with abacos
In order to integrate an order, the system must access Abacos WS
  
  Scenario: Order was already integrated
    Given an integrated order
    When the system checks it on abacos
    Then it must ensure that the HEAD is updated with order id

  Scenario: Order was not integrated
    Given an non-integrated order
    When the system checks it on abacos
    Then make a sanity check
    And it must send the order to abacos
    And mark it as sucessfully integrated
    And it must ensure that the HEAD is updated with order id
