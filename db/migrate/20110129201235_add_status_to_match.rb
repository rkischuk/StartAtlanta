class AddStatusToMatch < ActiveRecord::Migration
  def self.up
    add_column :matches, :status, :integer
  end

  def self.down
    remove_column :matches, :status
  end
end
