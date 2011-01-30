class User < ActiveRecord::Base

  has_many :matches1, :class_name => "Match", :foreign_key => 'match_id1'
  has_many :matches2, :class_name => "Match", :foreign_key => 'match_id2'
  has_many :recommendations, :class_name => "Match", :foreign_key => 'recommender_id'
  has_many :skipped, :class_name => "Match", :foreign_key => 'skipped_user_id'
  has_and_belongs_to_many :likes

  has_one :location
  has_many :interestedins
  has_many :meetingsfors

  def self.fromFacebookUserObj(fbUserObj)
    user = User.new do |u|
      u.fb_id               = fbUserObj.identifier

      if fbUserObj.respond_to?('profile') # if loading a friend vs the original person
        u.name                = fbUserObj.profile.name
        u.gender              = fbUserObj.profile.gender
        u.first_name          = fbUserObj.profile.first_name
        u.last_name           = fbUserObj.profile.last_name
        u.relationship_status = fbUserObj.profile.relationship_status
        u.birthday            = fbUserObj.profile.birthday
        u.locale              = fbUserObj.profile.locale
      else
        u.name                = fbUserObj.name
      end
    end

    user.save
    return user
  end

  def next_match( user_id )
    #generate match object from users friends
    #try to do this only for friends who have retrieved data already
    match = Match.new
  end

end
