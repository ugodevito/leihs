class Setting < ActiveRecord::Base

  validates_presence_of :smtp_address,
                        :smtp_port,
                        :smtp_domain,
                        :local_currency_string,
                        :contract_terms,
                        :contract_lending_party_string,
                        :email_signature,
                        :default_email,
                        :user_image_url,
                        :per_page

  validates_numericality_of :smtp_port, :per_page, :greater_than => 0

  validates_format_of :default_email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i

  def self.initialize_constants
    singleton = first # fetch the singleton from the database
    return unless singleton
    [:smtp_address,
     :smtp_port,
     :smtp_domain,
     :local_currency_string,
     :contract_terms,
     :contract_lending_party_string,
     :email_signature,
     :default_email,
     :deliver_order_notifications,
     :user_image_url,
     :per_page].each do |k|
      Setting.const_set k.to_s.upcase, singleton.send(k)
    end
  end

  # initialize the constants at the application startup
  initialize_constants

  before_create do
    raise "Setting is a singleton" if Setting.count > 0
  end

  after_save do
    self.class.initialize_constants
  end

end
