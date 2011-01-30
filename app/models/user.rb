class User < ActiveRecord::Base
  RELATIONSHIP = {
    :single => "Single"
  }


  has_many :person_a_matches, :class_name => "Match", :foreign_key => 'person_a_id'
  has_many :person_b_matches, :class_name => "Match", :foreign_key => 'person_b_id'
  has_many :recommendations, :class_name => "Match", :foreign_key => 'recommender_id'
  has_many :skipped, :class_name => "Match", :foreign_key => 'skipped_user_id'
  has_and_belongs_to_many :likes, :join_table => "users_likes"

  # from: http://railscasts.com/episodes/163-self-referential-association

  has_many :friendships
  has_many :friends, :through => :friendships, :source => :friend
  has_many :inverse_friendships, :class_name => "Friendship", :foreign_key => "friend_id"
  has_many :inverse_friends, :through => :inverse_friendships, :source => :user
  has_many :newmatches, :through => :friendships, :source => :friend, :conditions => "gender = 'female'"

  has_one :location
  has_many :interestedins
  has_many :meetingsfors

  validates_uniqueness_of :fb_id


  def self.fromFacebookUserObj(fbUserObj, full_retrieval = nil)
    user = User.find_by_fb_id(fbUserObj.identifier)
    if user.nil?
      user = User.new
      user.fb_id               = fbUserObj.identifier
    end

      if fbUserObj.respond_to?('profile') # think this iswhether this is the authenticated user or someone else
        fbUserObj = fbUserObj.profile
      end

      user.name                = fbUserObj.name
      user.gender              = fbUserObj.gender
      user.first_name          = fbUserObj.first_name
      user.last_name           = fbUserObj.last_name
      user.relationship_status = fbUserObj.relationship_status
      user.birthday            = fbUserObj.birthday
      user.locale              = fbUserObj.locale

      user.touch(:last_retrieved) if full_retrieval

    user.save
    return user
  end

  def populate_groups(group_list)
    group_list.each do |group|
      next if group.name.nil?
      
      Rails.logger.info "Logging " << group.name
      l = Like.find_by_fb_id(group.identifier)
      if l.nil?
        l = Like.new
        l.fb_id = group.identifier
        l.name = group.name
        l.link = group.endpoint
        l.save
      end
      
      self.likes << l
    end
    self.save
  end

  def populate_likes(like_list)
    like_list.each do |like|
      next if like.name.nil?
      
      Rails.logger.info "Logging " << like.name
      puts like.name
      l = Like.find_by_fb_id(like.identifier)
      if l.nil?
        l = Like.new
        l.fb_id = like.identifier
        l.name = like.name
        l.category = like.category
        l.link = like.endpoint
        l.save
      end
      
      self.likes << l
    end
    self.save
  end

  def next_match(person_id = nil)
    #Generates the next match for the provided person 
    #or generates a completely new match set
    #This match is saved!
    #Silently ignores person_id if invalid
    #But, returns nil if unable to generat a match

    person_a = person_id.nil? ? nil : friends.where("users.id = ?", person_id).first

    person_a = get_matchable_person if person_a.nil?

    return nil if person_a.nil?

    opposite_gender = person_a=="male" ? "female" : "male"
    person_b = get_matchable_person(opposite_gender)

    return nil if person_b.nil?

    m = Match.new
    m.status = Match::STATUS[:no]
    m.recommender_id = id
    m.person_a = person_a
    m.person_b = person_b
    #
    Rails.logger.info "Generating match between #{person_a.name} and #{person_b.name}"
    m.save and return m
  end

  protected
    def get_matchable_person(gender = nil)
      # > 18
      # 2) relationship_status = "not married"

      if gender.nil?
        return friends.where("relationship_status = 'Single' and (gender = 'male' or gender = 'female')").order("RANDOM()").first
      else
        return friends.where("relationship_status = 'Single' and (gender = ?)", gender).order("RANDOM()").first
      end

    end

    def youngest_birthdate()
      return 18.years.ago;

    end
end
