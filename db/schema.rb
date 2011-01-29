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

ActiveRecord::Schema.define(:version => 20110129173038) do

  create_table "facebooks", :force => true do |t|
    t.string   "identifier",   :limit => 20
    t.string   "access_token"
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

  create_table "matches", :force => true do |t|
    t.integer  "match_id1"
    t.integer  "match_id2"
    t.integer  "recommender_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "fb_id"
    t.string   "name"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "locale"
    t.string   "birthdate"
    t.string   "gender"
    t.datetime "last_retrieved"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users_likes", :id => false, :force => true do |t|
    t.integer "user_id"
    t.integer "like_id"
  end

end
