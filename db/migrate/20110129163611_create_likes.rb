class CreateLikes < ActiveRecord::Migration
  def self.up
    create_table :likes do |t|
      t.string :fb_id
      t.string :name
      t.string :picture
      t.string :link
      t.string :category
      t.string :website
      t.integer :likes

      t.timestamps
    end
  end

  def self.down
    drop_table :likes
  end
end
