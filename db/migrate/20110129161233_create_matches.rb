class CreateMatches < ActiveRecord::Migration
  def self.up
    create_table :matches do |t|
      t.integer :match_id1
      t.integer :match_id2
      t.integer :recommender_id

      t.timestamps
    end
  end

  def self.down
    drop_table :matches
  end
end
