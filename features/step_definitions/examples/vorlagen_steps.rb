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

Angenommen(/^ich befinde mich auf der Liste der Vorlagen$/) do
  visit backend_inventory_pool_templates_path(@current_inventory_pool)
end

Wenn(/^ich auf den Button "Neue Vorlage" klicke$/) do
  click_link _("New Template")
end

Dann(/^öffnet sich die Seite zur Erstellung einer neuen Vorlage$/) do
  current_path.should == new_backend_inventory_pool_template_path(@current_inventory_pool)
end

Wenn(/^ich den Namen der Vorlage eingebe$/) do
  pending # express the regexp above with the code you wish you had
end

Wenn(/^ich Modelle hinzufüge$/) do
  pending # express the regexp above with the code you wish you had
end

Dann(/^steht bei jedem Modell die höchst mögliche ausleihbare Anzahl der Gegenstände für dieses Modell$/) do
  pending # express the regexp above with the code you wish you had
end

Dann(/^für jedes hinzugefügte Modell ist die Mindestanzahl (\d+)$/) do |arg1|
  pending # express the regexp above with the code you wish you had
end

Wenn(/^ich zu jedem Modell die Anzahl angebe$/) do
  pending # express the regexp above with the code you wish you had
end

Wenn(/^ich speichere die Vorlage$/) do
  pending # express the regexp above with the code you wish you had
end

Dann(/^wurde die neue Vorlage mit all den erfassten Informationen erfolgreich gespeichert$/) do
  pending # express the regexp above with the code you wish you had
end

Dann(/^ich wurde auf die Liste der Vorlagen weitergeleitet$/) do
  pending # express the regexp above with the code you wish you had
end

Dann(/^ich sehe die Erfolgsbestätigung$/) do
  pending # express the regexp above with the code you wish you had
end
