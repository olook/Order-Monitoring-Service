Given /^an order id "(.*?)"$/ do |id|
  @id = id
end

When /^the system has processed the order already$/ do
  checker = OrderChecker.new
  checker.check
end

Then /^the system should keep its state idle$/ do
  @state = 'idle'
end

Then /^check for new orders within a period of time$/ do
  checker = OrderChecker.new(5000)
end

When /^the system has not processed the order yet$/ do
  pending # express the regexp above with the code you wish you had
end

Then /^the system should grab an order$/ do
  pending # express the regexp above with the code you wish you had
end

Then /^set it state to busy$/ do
  pending # express the regexp above with the code you wish you had
end
