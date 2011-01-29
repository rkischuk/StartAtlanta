class AddHighestEducationToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :highest_education, :string
  end

  def self.down
    remove_column :users, :highest_education
  end
end
