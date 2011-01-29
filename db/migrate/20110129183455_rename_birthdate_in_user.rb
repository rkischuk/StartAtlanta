class RenameBirthdateInUser < ActiveRecord::Migration
  def self.up
    change_table :users do |t|
      t.rename :birthdate, :birthday
    end
  end

  def self.down
    change_table :users do |t|
      t.rename :birthday, :birthdate
    end
  end
end
