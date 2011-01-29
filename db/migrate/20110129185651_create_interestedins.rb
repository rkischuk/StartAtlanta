class CreateInterestedins < ActiveRecord::Migration
  def self.up
    create_table :interestedins do |t|
      t.string :type

      t.timestamps
    end
  end

  def self.down
    drop_table :interestedins
  end
end
