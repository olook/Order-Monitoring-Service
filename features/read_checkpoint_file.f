Feature: Read checkpoint file through command line
In order to read the file content, as a sysadmin, I should
be able to provide some arguments through the command line

  Scenario: With a head argument
  Given that a file exists
  When I provide the head argument
  Then it should return the order that the head points to

  Scenario: With a failed argument
  Given that a file exists
  When I provide the failed argument
  Then it should return all orders that failed
  