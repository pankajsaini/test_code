class AuthenticationKey < ActiveRecord::Base
  attr_accessible :subdomain, :unique_identifier, :secret, :access_token, :token_type

  def self.authenticate_subdomain(subdomain)
    where(subdomain: subdomain).first
  end
end
