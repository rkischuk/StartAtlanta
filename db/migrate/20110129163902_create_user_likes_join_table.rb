class CreateUserLikesJoinTable < ActiveRecord::Migration
  def self.up
    create_table :users_likes, :id => false do |t|
      t.integer :user_id
      t.integer :like_id
    end
  end

  def self.down
    drop_table :users_likes
  end
end
