# -*- encoding : utf-8 -*-

Wenn(/^ich im Inventarbereich auf den Link "Vorlagen" klicke$/) do
  visit backend_inventory_pool_inventory_path(@current_inventory_pool)
  click_link _("Vorlagen")
end

Dann(/^öffnet sich die Seite mit der Liste der im aktuellen Inventarpool erfassten Vorlagen$/) do
  page.should have_content _("List of templates")
  @current_inventory_pool.templates.each do |t|
    page.should have_content t.name
  end
end

Dann(/^die Vorlagen für dieses Inventarpool sind alphabetisch nach Namen sortiert$/) do
  all_names = all(".line .modelname").map(&:text)
  all_names.sort.should == @current_inventory_pool.templates.sort.map(&:name)
  all_names.count.should == @current_inventory_pool.templates.count
end
