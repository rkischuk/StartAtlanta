# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20110130070726) do

  create_table "facebooks", :force => true do |t|
    t.string   "identifier",   :limit => 20
    t.string   "access_token"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
  end

  create_table "friendships", :id => false, :force => true do |t|
    t.integer "user_id"
    t.integer "friend_id"
  end

  create_table "interestedins", :force => true do |t|
    t.string   "type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "likes", :force => true do |t|
    t.string   "fb_id"
    t.string   "name"
    t.string   "picture"
    t.string   "link"
    t.string   "category"
    t.string   "website"
    t.integer  "likes"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "locations", :force => true do |t|
    t.string   "fb_id"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "matches", :force => true do |t|
    t.integer  "person_a_id"
    t.integer  "person_b_id"
    t.integer  "recommender_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "status"
    t.integer  "skipped_user_id"
  end

  create_table "meetingfors", :force => true do |t|
    t.string   "type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "fb_id"
    t.string   "name"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "locale"
    t.string   "birthday"
    t.string   "gender"
    t.datetime "last_retrieved"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "link"
    t.string   "relationship_status"
    t.string   "bio"
    t.string   "quotes"
    t.string   "religion"
    t.string   "political"
    t.boolean  "fb_verified"
    t.string   "updated_time"
    t.string   "highest_education"
  end

  create_table "users_likes", :id => false, :force => true do |t|
    t.integer "user_id"
    t.integer "like_id"
  end

end
