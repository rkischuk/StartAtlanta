class Match < ActiveRecord::Base
  STATUS = {
    :notselected => 0,
    :yes => 1,
    :no => 2,
    :skip => 3
  }

  belongs_to :person_a, :class_name =>"User"
  belongs_to :person_b, :class_name => "User"
  belongs_to :recommender, :class_name => "User"
  belongs_to :skipped_user, :class_name => "User", :primary_key => "skipped_user_id", :foreign_key => "user_id"


  def respondable_by(user)
    if status.nil? || status == STATUS[:notselected]
      if user == recommender
        return true
      end
    end
    
    return false
  end

end

