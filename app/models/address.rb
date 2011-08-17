class Address < ActiveRecord::Base

  geocoded_by :to_s
  
  before_save :geocode

  validates_uniqueness_of :street, :scope => [:zip_code, :city, :country_code]
  
  def to_s
    [street, zip_code, city, country].compact.join(', ')
  end
  
  def to_multiline_s
    [street, zip_code, city, country].compact.join('\r\n')
  end
  
  def country
    # TODO translate
    country_code
  end
  
  def coordinates
    if latitude.nil? or longitude.nil?
      geocode
    else
      [latitude, longitude]
    end
  end

end