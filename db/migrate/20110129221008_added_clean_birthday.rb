class AddedCleanBirthday < ActiveRecord::Migration
  def self.up
    add_column :users, :clean_birthday, :date
  end

  def self.down
    remove_column :users, :clean_birthday
  end
end
