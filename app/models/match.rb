class Match < ActiveRecord::Base
  STATUS = {
    :notselected => 0,
    :yes => 1,
    :no => 2,
    :skip => 3
  }

  belongs_to :person_a, :class_name =>"User"
  belongs_to :person_b, :class_name => "User"
  belongs_to :recommender_user, :class_name => "User", :primary_key => "recommender_id", :foreign_key => "user_id"
  belongs_to :skipped_user, :class_name => "User", :primary_key => "skipped_user_id", :foreign_key => "user_id"

end

