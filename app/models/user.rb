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

  def self.fromFacebookUserObj(fbUserObj, is_full_fetch = false)
    logger.info "fromFacebookUserObj"
    #will not populate friends, groups, likes
    #check first to see if there is an existing row in the database for this user
    user = User.find_by_fb_id(fbUserObj.identifier)
    user = User.new if user.nil?

    user.populate_from_fbUser(fbUserObj, is_full_fetch)
    return user
  end

  def fetch_and_populate()
      return false if fb_id.nil?

      fbObj = FbGraph::User.fetch(fb_id, :access_token => current_user.access_token)
      populate_from_fbUser(fbObj)
  end

  def fetch_and_populate_by_fb_id(new_fb_id)
    return false if new_fb_id.nil?

    self.fb_id = new_fb_id
    fetch_and_populate
  end

  def populate_from_fbUser(fbUserObj, is_full_fetch = false)
    logger.info "populate_from_fbUser"
    #will not populate friends, groups, likes
    #return boolean
      if fbUserObj.respond_to?('profile') # think this iswhether this is the authenticated user or someone else
        fbUserObj = fbUserObj.profile
      end

      self.fb_id               = fbUserObj.identifier
      self.name                = fbUserObj.name
      self.gender              = fbUserObj.gender
      self.first_name          = fbUserObj.first_name
      self.last_name           = fbUserObj.last_name
      self.relationship_status = fbUserObj.relationship_status
      self.birthday            = fbUserObj.birthday
      self.locale              = fbUserObj.locale
      self.link                = fbUserObj.link
      self.bio                 = fbUserObj.bio[0,254] rescue nil
      self.quotes              = fbUserObj.quotes[0,254] rescue nil
      self.religion            = fbUserObj.religion
      self.political           = fbUserObj.political
      self.fb_verified         = fbUserObj.verified
      self.updated_time        = fbUserObj.updated_time
      self.email               = fbUserObj.email
      self.highest_education   = get_highest_education_level(fbUserObj.education)

      unless fbUserObj.birthday.nil? || fbUserObj.birthday.year == 0
        self.clean_birthday = fbUserObj.birthday
      end

      self.touch(:last_retrieved) if is_full_fetch

      self.save
  end

  def populate_friends(friends_list)
    #friends_list is an array of friends from fbGraph
    #populates database with list of friends
    #does not retrieved detailed friend information
    friends_list.each do |friend_object|
      logger.info(ActiveSupport::JSON.encode(friend_object))
      f = User.find_by_fb_id(friend_object.identifier)
      f = User.fromFacebookUserObj(friend_object, false) if f.nil?

      friendships.build(:friend_id => f.id)
      self.save
    end

  end

  def fetch_and_populate_friend_details(num = nil, token = nil)
    if num.nil?
      friends_list = friends.where('"users".last_retrieved IS NULL')
    else
      friends_list = friends.where('"users".last_retrieved IS NULL').limit(num)
    end

    token = current_user.access_token if token.nil?

    friends_list.each do |f|
      friendFb = FbGraph::User.fetch(f.fb_id, :access_token => token)
      u = User.fromFacebookUserObj(friendFb, true)
    end
  end

  def has_unretrieved_friends
    friends.where('"users".last_retrieved IS NULL').count > 0
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

    opposite_gender = (person_a.gender =="male") ? "female" : "male"

    person_b = get_matchable_person(opposite_gender)

    return nil if person_b.nil?

    m = Match.new
    m.status = Match::STATUS[:notselected]
    m.recommender = self
    m.person_a = person_a
    m.person_b = person_b
    #
    Rails.logger.info "Generating match between #{person_a.name} and #{person_b.name}"
    m.save and return m
  end

  protected
    def get_highest_education_level(education_array)
      return ""
    end

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
