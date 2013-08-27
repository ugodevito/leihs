Given /^I try to approve an order that has problems$/ do
  @unapprovable_order =  @ip.orders.detect{|o| not o.approvable?}
  find(".toggle .text").click
  find(".order.line[data-id='#{@unapprovable_order.id}'] .actions .button", :text => _("Approve")).click
  find(".dialog")
end

Then /^I got an information that this order has problems$/ do
  find(".dialog .flash_message.visible")
end

When /^I approve anyway$/ do
  find(".dialog .navigation .alternatives .trigger").click
  find(".dialog .navigation .button[name='force']").click
  all(".dialog").size.should == 0
end

Then /^this order is approved$/ do
  @unapprovable_order.reload.status_const.should == Order::APPROVED
  all(".order.line[data-id='#{@unapprovable_order.id}']").size.should == 0
end