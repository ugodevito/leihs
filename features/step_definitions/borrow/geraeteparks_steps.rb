# -*- encoding : utf-8 -*-  

Wenn(/^ich den Gerätepark Link drücke$/) do
  visit borrow_root_path
  find("a[href='#{borrow_inventory_pools_path}']").click
end

Dann(/^sehe ich die Geräteparks für die ich berechtigt bin$/) do
  @current_user.inventory_pools.each do |ip|
    page.should have_content ip.name
  end
end

Dann(/^sehe die Beschreibung für jeden Gerätepark$/) do
  @current_user.inventory_pools.each do |ip|
    ip.description.split(/\n/).each do |text|
      page.should have_content text
    end
  end
end