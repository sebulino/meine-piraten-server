# frozen_string_literal: true

class DeviseCreateUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :users do |t|
      t.string :provider, null: false, default: "openid_connect"
      t.string :uid, null: false
      t.string :email
      t.string :name
      t.string :preferred_username

      # Devise trackable
      t.integer :sign_in_count, default: 0, null: false
      t.datetime :current_sign_in_at
      t.datetime :last_sign_in_at
      t.string :current_sign_in_ip
      t.string :last_sign_in_ip

      # OIDC tokens for logout/refresh
      t.text :refresh_token
      t.datetime :token_expires_at

      t.timestamps null: false
    end

    add_index :users, [:provider, :uid], unique: true
    add_index :users, :email
  end
end
