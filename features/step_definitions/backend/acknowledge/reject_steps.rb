When /^I open the daily view$/ do
  @ip = @current_user.managed_inventory_pools.first
  visit backend_inventory_pool_path @ip
end

When /^I reject an order$/ do
  @order = @ip.orders.submitted.first
  find(".toggle .text").click
  binding.pry
  find(".order .list .line[data-id='#{@order.id}']")
  find(".order .list .line[data-id='#{@order.id}'] .actions .trigger").click
  find(".order .list .line[data-id='#{@order.id}'] .actions .button", :text => _("Reject")).click
end

Then /^I see a summary of that order$/ do
  find(".dialog")
  unless @order.purpose.description.nil?
    find(".dialog .purpose").should have_content @order.purpose.description[0..25]
  end
end

Then /^I can write a reason why I reject that order$/ do
  find("#comment").set "you are not allowed to get these things"
end

When /^I reject the order$/ do
  find(".dialog .button[type=submit]").click
end

Then /^the order is rejected$/ do
  page.should_not have_selector(".order .list .line[data-id='#{@order.id}']")
  @order.reload.status_const.should == Order::REJECTED 
end

Then /^the counter of that list is updated/ do
  find(".order .list .line").find(:xpath, "../..").find(".badge").text.to_i.should == @ip.orders.submitted.count
end