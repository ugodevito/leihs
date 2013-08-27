# encoding: utf-8

def fill_in_autocomplete_field field_name, field_value
  find(".field", text: field_name).find("input").set field_value
  find(".field", text: field_name).find("input").click
  all("a", text: field_value).empty?.should be_false
  find(".field", text: field_name).find("a", text: field_value).click
end

def check_fields_and_their_values table
  table.hashes.each do |hash_row|
    field_name = hash_row["Feldname"]
    field_value = hash_row["Wert"]
    field_type = hash_row["Type"]

    within find(".field", text: field_name) do
      case field_type
      when "autocomplete"
        find("input,textarea").value.should == (field_value != "Keine/r" ? field_value : "")
      when "select"
        all("option").detect(&:selected?).text.should == field_value
      when "radio must"
        find("input[checked][type='radio']").value.should == field_value
      when "radio"
        find("label", text: field_value).find("input").checked?.should be_true
      else
        find("input,textarea").value.should == field_value
      end
    end
  end
end

Angenommen /^man befindet sich auf der Liste des Inventars$/ do
  visit backend_inventory_pool_inventory_path(@current_inventory_pool)
end

Dann /^kann man einen Gegenstand erstellen$/ do
  page.execute_script("$('.content_navigation .arrow').trigger('mouseover');")
  click_link _("Create %s") % _("Item")
  current_path.should eql new_backend_inventory_pool_item_path(@current_inventory_pool)
end

Angenommen /^man navigiert zur Gegenstandserstellungsseite$/ do
  visit new_backend_inventory_pool_item_path(@current_inventory_pool)
end

Wenn /^ich die folgenden Informationen erfasse$/ do |table|
  @table_hashes = table.hashes

  @table_hashes.each do |hash_row|
    field_name = hash_row["Feldname"]
    field_value = hash_row["Wert"]
    field_type = hash_row["Type"]

    case field_type
    when "radio must"
      all("form").last.find(".field", text: field_name).find("input[value='#{field_value}']").set true
    when "checkbox"
      all("form").last.find(".field", text: field_name).find("input").set true if field_value == "checked"
    when "select"
      all("form").last.find(".field", text: field_name).select field_value
    when "autocomplete"
      all("form").last.find(".field", text: field_name).find("input").set field_value
      all("form").last.find(".field", text: field_name).find("input").click
      all("a", text: field_value).empty?.should be_false
      all("form").last.find(".field", text: field_name).find("a", text: field_value).click
    else
      all("form").last.find(".field", text: field_name).find("input,textarea").set field_value
    end
  end
end

Wenn /^ich erstellen druecke$/ do
  find("button", text: _("Save %s") % _("Item")).click
  step "ensure there are no active requests"
end

Dann /^ist der Gegenstand mit all den angegebenen Informationen erstellt$/ do
  find("a[data-tab*='retired']").click if (@table_hashes.detect {|r| r["Feldname"] == "Ausmusterung"} ["Wert"]) == "Ja"
  find_field('query').set (@table_hashes.detect {|r| r["Feldname"] == "Inventarcode"} ["Wert"])
  all("li.modelname").first.text.should =~ /#{@table_hashes.detect {|r| r["Feldname"] == "Modell"} ["Wert"]}/
  find(".toggle .icon").click
  find(".button", text: 'Gegenstand editieren').click

  all("form").count.should == 2
  step 'hat der Gegenstand alle zuvor eingetragenen Werte'
end

Dann /^hat der Gegenstand alle zuvor eingetragenen Werte$/ do
  @table_hashes.each do |hash_row|
    field_name = hash_row["Feldname"]
    field_value = hash_row["Wert"]
    field_type = hash_row["Type"]

    case field_type
    when "autocomplete"
      all("form").last.find(".field", text: field_name).find("input,textarea").value.should == (field_value != "Keine/r" ? field_value : "")
    when "select"
      all("form").last.find(".field", text: field_name).all("option").detect(&:selected?).text.should == field_value
    when "radio must"
      all("form").last.find(".field", text: field_name).find("input[checked][type='radio']").value.should == field_value
    when ""
      all("form").last.find(".field", text: field_name).find("input,textarea").value.should == field_value
    end
  end
end

Dann /^man wird zur Liste des Inventars zurueckgefuehrt$/ do
  current_path.should eql backend_inventory_pool_inventory_path(@current_inventory_pool)
end

Wenn /^jedes Pflichtfeld ist gesetzt$/ do |table|
  table.raw.flatten.each do |must_field_name|
    case must_field_name
    when "Inventarcode"
      @inventory_code_value = "test"
      @inventory_code_field = find(".field", text: must_field_name).find("input,textarea")
      @inventory_code_field.set @inventory_code_value
    when "Modell"
      model_name = Model.first.name
      fill_in_autocomplete_field must_field_name, model_name
    when "Projektnummer"
      find(".field", text: "Bezug").find("input[value='investment']").set true
      @project_number_value = "test"
      @project_number_field = find(".field", text: must_field_name).find("input,textarea")
      @project_number_field.set @project_number_value
    when "Anschaffungskategorie"
      find(".field", text: "Anschaffungskategorie").find("select option[value!='']").select_option
    else
      raise 'unknown field'
    end
  end
end

Wenn /^kein Pflichtfeld ist gesetzt$/ do |table|
  table.raw.flatten.each do |must_field_name|
    case must_field_name
      when "Inventarcode"
        find(".field", text: must_field_name).find("input,textarea").set ""
      when "Modell"
        find(".field", text: must_field_name).find("input").set ""
      when "Projektnummer"
        find(".field", text: "Bezug").find("input[value='investment']").set true
        find(".field", text: must_field_name).find("input,textarea").set ""
      when "Anschaffungskategorie"
        find(".field", text: "Anschaffungskategorie").find("select option[value='']").select_option
      else
        raise 'unknown field'
    end
  end
end

Wenn /^ich das gekennzeichnete "(.+)" leer lasse$/ do |must_field_name|
  @must_field_name = must_field_name
  if not find(".field", text: @must_field_name).all("input,textarea").empty?
    find(".field", text: @must_field_name).find("input,textarea").set ""
  elsif not find(".field", text: @must_field_name).all("select").empty?
    find(".field", text: @must_field_name).find("select option[value='']").select_option
  else
    raise "unkown field"
  end
end

Dann /^kann das Modell nicht erstellt werden$/ do
  step "ich erstellen druecke"
  step "ensure there are no active requests"
  Item.find_by_inventory_code("").should be_nil
  Item.find_by_inventory_code("test").should be_nil
end

Dann /^die anderen Angaben wurde nicht gelöscht$/ do
  if @must_field_name == "Modell"
    @inventory_code_field.value.should eql @inventory_code_value
    @project_number_field.value.should eql @project_number_value
  end
end

Dann /^ist der Barcode bereits gesetzt$/ do
  find(".field", text: "Inventarcode").find("input").value.should_not be_empty
end

Dann /^Letzte Inventur ist das heutige Datum$/ do
  find(".field", text: "Letzte Inventur").find("input").value.should eq Date.today.strftime("%d.%m.%Y")
end

Dann /^folgende Felder haben folgende Standardwerte$/ do |table|
  check_fields_and_their_values table
end

Angenommen(/^man setzt Bezug auf Investition$/) do
  find("input[name='item[properties][reference]'][value='investment']").click
end

Dann(/^sind die folgenden Werte im Feld Anschaffungskategorie hinterlegt$/) do |table|
  @table_hashes = table.hashes
  @table_hashes.each do |hash|
    find("select[name='item[properties][anschaffungskategorie]'] option[value='#{hash.values.first}']").select_option
  end
end
