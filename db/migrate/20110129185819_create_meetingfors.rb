class CreateMeetingfors < ActiveRecord::Migration
  def self.up
    create_table :meetingfors do |t|
      t.string :type

      t.timestamps
    end
  end

  def self.down
    drop_table :meetingfors
  end
end
