class AddSkippedUserIdToMatches < ActiveRecord::Migration
  def self.up
    add_column :matches, :skipped_user_id, :integer
  end

  def self.down
    remove_column :matches, :skipped_user_id
  end
end
