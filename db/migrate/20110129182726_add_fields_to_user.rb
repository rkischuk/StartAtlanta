class AddFieldsToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :link, :string
    add_column :users, :relationship_status, :string
    add_column :users, :bio, :string
    add_column :users, :quotes, :string
    add_column :users, :religion, :string
    add_column :users, :political, :string
    add_column :users, :fb_verified, :boolean
    add_column :users, :updated_time, :string
  end

  def self.down
    remove_column :users, :updated_time
    remove_column :users, :fb_verified
    remove_column :users, :political
    remove_column :users, :religion
    remove_column :users, :quotes
    remove_column :users, :bio
    remove_column :users, :relationship_status
    remove_column :users, :link
  end
end
