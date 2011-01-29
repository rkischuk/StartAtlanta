class Match < ActiveRecord::Base
  belongs_to :match1, :class_name =>"User", :primary_key => "match_id1", :foreign_key => "user_id"
  belongs_to :match2, :class_name => "User", :primary_key => "match_id2", :foreign_key => "user_id"
  belongs_to :recommender_user, :class_name => "User", :primary_key => "recommender_id", :foreign_key => "user_id"
  belongs_to :skipped_user, :class_name => "User", :primary_key => "skipped_user_id", :foreign_key => "user_id"
end

