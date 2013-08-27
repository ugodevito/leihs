# -*- encoding : utf-8 -*-

Angenommen(/^ich befinde mich in der Liste des Inventars$/) do
  step 'man öffnet die Liste des Inventars'
end

Angenommen(/^ich die Navigation der Kategorien aufklappe$/) do
  find(".explorative-search-toggle").click
  all(".explorative-entry").empty?.should be_false
end

Wenn(/^ich eine Kategorie anwähle$/) do
  find("body").click
  @category_el = find(".explorative-entry")
  @category = Category.find @category_el[:"data-id"]
  @category_el.click
end

Dann(/^sehe ich die darunterliegenden Kategorien$/) do
  @category.children.each do |child|
    find(".explorative-entry", :text => child.name)
  end
end

Dann(/^kann die darunterliegende Kategorie anwählen$/) do
  @child_el = find(".explorative-entry")
  @child_category = Category.find @child_el[:"data-id"]
  @child_el.click
end

Dann(/^ich sehe die Hauptkategorie sowie die aktuell ausgewählte und die darunterliegenden Kategorien$/) do
  find(".explorative-top", :text => @category.name)
  find(".explorative-current", :text => @child_category.name)
end

Dann(/^das Inventar wurde nach dieser Kategorie gefiltert$/) do
  all(".line.model").each_with_index do |model_line, i|
    model = Model.find_by_name model_line.find(".modelname").text
    (model.categories.include?(@child_category) or @child_category.descendants.any? {|c| model.categories.include? c}).should be_true
  end
end

Dann(/^ich kann in einem Schritt auf die aktuelle Hauptkategorie zurücknavigieren$/) do
  find(".explorative-top").click
  step 'sehe ich die darunterliegenden Kategorien'
end

Dann(/^ich kann in einem Schritt auf die Übersicht der Hauptkategorien zurücknavigieren$/) do
  find(".explorative-current").click
  Category.roots.each do |child|
    find(".explorative-entry", :text => child.name)
  end
end

Wenn(/^ich die Navigation der Kategorien wieder zuklappe$/) do
  find(".explorative-search-toggle").click
end

Dann(/^sehe ich nur noch die Liste des Inventars$/) do
  all(".explorative-navigation", :visible => true).empty?.should be_true
end

Angenommen(/^die Navigation der Kategorien ist aufgeklappt$/) do
  step 'ich die Navigation der Kategorien aufklappe'
end

Wenn(/^ich nach dem Namen einer Kategorie suche$/) do
  @category = Category.first
  @search_term = @category.name[0..2]
  find(".explorative-search").set @search_term
  find(".explorative-current", :text => @search_term)
end

Dann(/^werden alle Kategorien angezeigt, welche den Namen beinhalten$/) do
  Category.all.map(&:name).reject{|name| ! name[@search_term]}.each do |name|
    find(".explorative-entry", :text => name)
  end
  all(".explorative-entry").size.should == all(".explorative-entry", :text => @search_term).size
end

Dann(/^ich wähle eine Kategorie$/) do
  step 'ich eine Kategorie anwähle'
end

Dann(/^ich sehe ein Suchicon mit dem Namen des gerade gesuchten Begriffs sowie die aktuell ausgewählte und die darunterliegenden Kategorien$/) do
  find(".explorative-top .search.icon")
  find(".explorative-top", :text => @search_term)
  find(".explorative-current", :text => @child_category.name)
  @child_category.children.each do |child|
    find(".explorative-entry", :text => child.name)
  end
end

Angenommen(/^ich befinde mich in der Unterkategorie der explorativen Suche$/) do
  step 'man öffnet die Liste des Inventars'
  step 'ich die Navigation der Kategorien aufklappe'
  step 'ich eine Kategorie anwähle'
end

Dann(/^kann ich in die übergeordnete Kategorie navigieren$/) do
  find(".explorative-current").click
end

Angenommen(/^ich befinde mich in der Liste der Modelle$/) do
  step 'man öffnet die Liste der Modelle'
end

Dann(/^die Modelle wurden nach dieser Kategorie gefiltert$/) do
  step "das Inventar wurde nach dieser Kategorie gefiltert"
end

Angenommen(/^ich befinde mich in einer Bestellung$/) do
  step 'ich öffne eine Bestellung'
end

Dann(/^kann ich ein Modell anhand der explorativen Suche wählen$/) do
  find("#process_helper *[type='submit']").click
  all(".dialog .line").empty?.should be_false
  find(".explorative-entry").click
  model = Model.find find(".dialog .line")["data-id"]
  find(".line button.select-model").click
  all(".notification").empty?.should be_false
  if @order
    expect(@order.models.include? model).to be_true
  else
    expect(@customer.contracts.map(&:models).flatten.include? model).to be_true
  end
end

Dann(/^die explorative Suche zeigt nur Modelle aus meinem Park an$/) do
  find("#process_helper *[type='submit']").click
  all(".dialog .line").empty?.should be_false
  all(".dialog .model.line").each do |line|
    model = Model.find line["data-id"]
    expect(@current_inventory_pool.models.include? model).to be_true
  end
end

Dann(/^die nicht verfügbaren Modelle sind rot markiert$/) do
  all(".model.line .availability", :text => /0 \(\d+\) \/ \d+/).each do |cell|
    line = cell.find(:xpath, "./../..")
    (line[:class] =~ /error/).should_not be_nil
  end
end
