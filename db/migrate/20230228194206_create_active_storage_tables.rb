# frozen_string_literal: true

# Migration
class CreateActiveStorageTables < ActiveRecord::Migration[7.0]
  def change
    create_table :active_storage_blobs, if_not_exists: true do |t|
      t.string :key, null: false
      t.string :filename, null: false
      t.string :content_type
      t.text :metadata
      t.string :service_name, null: false
      t.bigint :byte_size, null: false
      t.string :checksum
      t.datetime :created_at, null: false

      t.index [:key], name: 'index_active_storage_blobs_on_key', unique: true
    end

    create_table :active_storage_attachments do |t|
      t.string :name, null: false
      t.string :record_type, null: false
      t.bigint :record_id, null: false
      t.bigint :blob_id, null: false
      t.datetime :created_at, null: false

      t.index [:blob_id], name: 'index_active_storage_attachments_on_blob_id'
      t.index %i[record_type record_id name blob_id], name: 'index_active_storage_attachments_uniqueness',
                                                      unique: true
    end

    # add_foreign_key :active_storage_attachments, :active_storage_blobs, column: :blob_id
  end
end
