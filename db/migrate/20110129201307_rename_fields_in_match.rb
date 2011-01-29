class RenameFieldsInMatch < ActiveRecord::Migration
  def self.up
    rename_column :matches, :match_id1, :person_a
    rename_column :matches, :match_id2, :person_b
  end

  def self.down
    rename_column :matches, :person_a, :match_id1
    rename_column :matches, :person_b, :match_id2
  end
end
