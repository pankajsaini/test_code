class CreateAuthenticationKeys < ActiveRecord::Migration
  def change
    create_table :authentication_keys do |t|
      t.string :subdomain
      t.string :unique_identifier
      t.string :secret
      t.string :access_token
      t.string :token_type

      t.timestamps
    end
  end
end
