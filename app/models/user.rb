class User < ActiveRecord::Base
  has_many :matches1, :class_name => "Match", :foreign_key => 'match_id1'
  has_many :matches2, :class_name => "Match", :foreign_key => 'match_id2'
  has_many :recommendations, :class_name => "Match", :foreign_key => 'recommender_id'
  has_and_belongs_to_many :likes

  has_one :location
  has_many :interestedins
  has_many :meetingsfors

  def getNextMatch(current_user) 
    match = nil
    match = Match.first
    =>#<status: 0, recommender_id: current_user>
    if match.nil? then
        match = generate_matches(current_user)
    else
        match.status = "1"
    end
    return match
  end

  def generate_matches(current_user)
    return nil
  end
end


