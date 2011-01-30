class RenameMatchFields < ActiveRecord::Migration
  def self.up
    rename_column :matches, :person_a, :person_a_id
    rename_column :matches, :person_b, :person_b_id
  end

  def self.down
    rename_column :matches, :person_a_id, :person_a
    rename_column :matches, :person_b_id, :person_b
  end
end
