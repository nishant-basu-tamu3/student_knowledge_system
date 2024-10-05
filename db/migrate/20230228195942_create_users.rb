# frozen_string_literal: true

# Migration
class CreateUsers < ActiveRecord::Migration[6.1]
  def change
    create_table :users do |t|
      t.string :email, null: false, default: ''
      t.string :encrypted_password, null: false, default: ''
      t.string :full_name
      t.string :uid
      t.string :avatar_url
      t.string :provider
      t.string :reset_password_token
      t.datetime :reset_password_sent_at
      t.datetime :remember_created_at
      t.string :confirmation_token
      t.datetime :confirmed_at
      t.datetime :confirmation_sent_at
      t.string :unconfirmed_email
      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false
      t.string :firstname, default: ''
      t.string :lastname, default: ''

      # t.index :email, unique: true
      # t.index :reset_password_token, unique: true
      # t.index :confirmation_token, unique: true
      t.index ['confirmation_token'], name: 'index_users_on_confirmation_token', unique: true
      t.index ['email'], name: 'index_users_on_email', unique: true
      t.index ['reset_password_token'], name: 'index_users_on_reset_password_token', unique: true
    end
  end
end
