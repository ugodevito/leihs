# -*- encoding : utf-8 -*-

Wenn /^ein Zweck gespeichert wird ist er unabhängig von einer Bestellung$/ do
  purpose = FactoryGirl.create :purpose
  lambda{ purpose.order }.should raise_error(NoMethodError)
end

Wenn /^jeder Eintrag einer Bestellung referenziert auf einen Zweck$/ do
  FactoryGirl.create(:order_with_lines).lines.each do |line|
    line.purpose.should be_a_kind_of Purpose
  end
end

Wenn /^jeder Eintrag eines Vertrages kann auf einen Zweck referenzieren$/ do
  FactoryGirl.create(:contract_with_lines).lines.each do |line|
    line.purpose = FactoryGirl.create :purpose
    line.purpose.should be_a_kind_of Purpose
  end
end

Wenn /^ich eine Bestellung genehmige$/ do
  step 'I open an order for acknowledgement'
end

Dann /^sehe ich den Zweck$/ do
  if @order.lines.first.purpose
    page.should have_content @order.lines.first.purpose.description
  end
end

Wenn /^ich eine Aushändigung mache$/ do
  step 'I open a hand over'
end

Dann /^sehe ich auf jeder Zeile den zugewisenen Zweck$/ do
  @customer.contracts.unsigned.first.lines.each do |line|
    find(".line[data-id='#{line.id}']").should have_content line.model.name
    find(".line[data-id='#{line.id}']").should have_content line.purpose.description[0..10]
  end
end

Dann /^kann ich den Zweck editieren$/ do
  find(".button", :text => /(Edit Purpose|Zweck editieren)/).click
  @new_purpose_description = "Benötigt für die Sommer-Austellung"
  wait_until{ find(".dialog #purpose") }.set @new_purpose_description
  find(".dialog button[type=submit]").click
  wait_until{ all(".dialog", :visible => true).empty? }
  @order.reload.lines.first.purpose.description.should == @new_purpose_description
  find("section.purpose").should have_content @new_purpose_description 
end

Dann /^kann ich einen Zweck hinzufügen$/ do
  step 'I click an inventory code input field of an item line'
  step 'I select one of those'
  find("#hand_over_button").click
  wait_until { find(".dialog .purpose") }
  find(".purpose .button").click
  find("#purpose")
end

Wenn /^keine der ausgewählten Gegenstände hat einen Zweck angegeben$/ do
  step 'I add an item to the hand over by providing an inventory code and a date range'
  step 'I add an option to the hand over by providing an inventory code and a date range'
end

Dann /^werde ich beim Aushändigen darauf hingewiesen einen Zweck anzugeben$/ do
  find("#hand_over_button").click
  wait_until{ find(".dialog .button") }
  find(".purpose #purpose")
end

Dann /^erst wenn ich einen Zweck angebebe$/ do
  find(".dialog .button[type=submit]", :text => /(Hand Over|Aushändigen)/).click
  wait_until { find(".notification") }
  find(".dialog #purpose").set "The purpose for this hand over"
end

Dann /^kann ich die Aushändigung durchführen$/ do
  signed_contracts_size = @customer.contracts.signed.size
  wait_until { find(".dialog .button[type=submit]", :text => /(Hand Over|Aushändigen)/) }
  step 'I click hand over inside the dialog'
  @customer.contracts.signed.size.should > signed_contracts_size
end

Wenn /^einige der ausgewählten Gegenstände hat keinen Zweck angegeben$/ do
  step 'I click an inventory code input field of an item line'
  step 'I select one of those'
  step 'I add an item to the hand over by providing an inventory code and a date range'
  step 'I add an option to the hand over by providing an inventory code and a date range'
end

Dann /^muss ich keinen Zweck angeben um die Aushändigung durchzuführen$/ do
  find("#hand_over_button").click
  wait_until { find(".dialog .button") }
  step 'kann ich die Aushändigung durchführen'
end

Wenn /^ich einen Zweck angebe$/ do
  find("#hand_over_button").click
  wait_until{ find(".dialog .button") }
  find(".purpose .button").click
  @added_purpose = "Another Purpose"
  find("#purpose").set @added_purpose
  @unsigned_lines = @customer.contracts.unsigned.first.lines
  step 'kann ich die Aushändigung durchführen'
end

Dann /^wird nur den Gegenständen ohne Zweck der angegebene Zweck zugewiesen$/ do
  @unsigned_lines.select{|l| l.purpose.blank?}.each do |line|
    line.purpose.description.should == @added_purpose
  end
end

Wenn /^alle der ausgewählten Gegenstände haben einen Zweck angegeben$/ do
  @contract = @customer.contracts.unsigned.first
  @contract.lines.where(ContractLine.arel_table[:start_date].lteq(Date.today)).each do |line|
    @item_line = line
    step 'I select one of those'
  end
  all(".line.assigned .select input").each do |select|
    select.click unless select.selected?
  end
  find("#hand_over_button").click
  wait_until { find(".dialog .purpose") }
end

Dann /^kann ich keinen weiteren Zweck angeben$/ do
  all(".dialog .purpose button", :visible => true).size.should == 0
end