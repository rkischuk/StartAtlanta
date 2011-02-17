class User
  include MongoMapper::Document
  many :authentications
  many :matches, :class_name => 'Match'
  # Basic cache of friend ids (by fb_id) to be loaded later
  key :unmapped_friend_ids, Array
  # Actual list of loaded friends
  key :friend_ids, Array, :typecast => 'ObjectId'
  many :friends, :class_name => 'User', :in => :friend_ids

  ensure_index 'friend_ids'
  ensure_index([[:friend_ids, 1], [:relationship_status, 1], [:gender, 1]])

  #has_many :person_a_matches, :class_name => "Match", :foreign_key => 'person_a_id'
  #has_many :person_b_matches, :class_name => "Match", :foreign_key => 'person_b_id'
  #has_many :recommendations, :class_name => "Match", :foreign_key => 'recommender_id'
  #has_many :skipped, :class_name => "Match", :foreign_key => 'skipped_user_id'
  #has_and_belongs_to_many :likes, :join_table => "users_likes"

  # from: http://railscasts.com/episodes/163-self-referential-association

  #has_many :friendships
  #has_many :friends, :through => :friendships, :source => :friend
  #has_many :inverse_friendships, :class_name => "Friendship", :foreign_key => "friend_id"
  #has_many :inverse_friends, :through => :inverse_friendships, :source => :user
  #has_many :newmatches, :through => :friendships, :source => :friend, :conditions => "gender = 'female'"

  #has_one :location
  #has_many :interestedins
  #has_many :meetingsfors

  key :fb_id, String
  key :name, String
  key :first_name, String
  key :last_name, String
  key :locale, String
  key :birthday, Time
  key :birthday_string, String
  key :gender, String
  key :link, String
  key :relationship_status, String
  key :bio, String
  key :quotes, String
  key :religion, String
  key :political, String
  key :fb_verified, Boolean
  key :education, String
  key :email, String
  key :last_crawled, Time
  key :friends_list_fetched, Boolean, :default => false
  key :has_matches, Boolean

  def unfetched_friends
    return friend_ids - friends.collect {|f| f.fb_id}
  end

  def fromFacebookUserObj(fbUserObj, is_full_fetch = false)
    #will not populate friends, groups, likes
    #check first to see if there is an existing row in the database for this user
    populate_from_fbUser(fbUserObj, is_full_fetch)
  end

  def populate_friend(friend_fb_id)
    u = User.find_by_fb_id(friend_fb_id)
    token = authentications[0].access_token


    u ||= User.new
    
    if u.last_crawled.nil?
      Rails.logger.info "Grabbing user from Facebook " + friend_fb_id
      fbData = FbGraph::User.fetch(friend_fb_id, :access_token => token)
      Rails.logger.info "Done grabbing user from Facebook " + friend_fb_id
      u.populate_from_fbUser(fbData, true)
    else
      Rails.logger.info "Using already-loaded Facebook user " + friend_fb_id
    end

    self.add_to_set(:friend_ids => u.id)
    u.add_to_set(:friend_ids => self.id)

    return u
  end

  def self.populate_from_facebook(fb_id, access_token)
    u = User.find_by_fb_id(fb_id)
    u ||= User.new

    Rails.logger.info "Grabbing user from Facebook " + fb_id
    fbData = FbGraph::User.fetch(fb_id, :access_token => access_token)
    Rails.logger.info "Done grabbing user from Facebook " + fb_id
    u.populate_from_fbUser(fbData, true)

    u
  end

  def populate_from_fbUser(fbUserObj, is_full_fetch = false)
    Rails.logger.info "populate_from_fbUser"
    #will not populate friends, groups, likes
    #return boolean
      if fbUserObj.respond_to?('profile') # think this is whether this is the authenticated user or someone else
        fbUserObj = fbUserObj.profile
      end

      Rails.logger.info("Populating " + (fbUserObj.name.nil? ? '' : fbUserObj.name) + ", gender " + (fbUserObj.gender.nil? ? '' : fbUserObj.gender))

      updates = {
        :fb_id => fbUserObj.identifier,
        :name => fbUserObj.name,
        :gender => fbUserObj.gender,
        :first_name => fbUserObj.first_name,
        :last_name => fbUserObj.last_name,
        :relationship_status => fbUserObj.relationship_status,
        :birthday_string => fbUserObj.birthday,
        :locale => fbUserObj.locale,
        :link => fbUserObj.link,
        :bio => fbUserObj.bio,
        :quotes => fbUserObj.quotes,
        :religion => fbUserObj.religion,
        :political => fbUserObj.political,
        :fb_verified => fbUserObj.verified,
        :email => fbUserObj.email,
        :education => fbUserObj.education
      }
      if is_full_fetch
        updates[:last_crawled]        = Time.now
      end

      unless fbUserObj.birthday.nil? || fbUserObj.birthday.year == 0
        updates[:birthday] = fbUserObj.birthday
      end
      self.update_attributes(updates)

  end

  def populate_friends(friends_list)
    #friends_list is an array of friends from fbGraph
    #populates database with list of friends
    #does not retrieved detailed friend information
    friends_list.each do |friend_object|
      f = User.find_by_fb_id(friend_object.identifier)
      f = User.fromFacebookUserObj(friend_object, false) if f.nil?

      friend_ids << f.fb_id
      self.save
    end

  end

  # Main method to populate friend list details
  def fetch_and_populate_friend_details(num = nil, token = nil)
    
    friends_list = self.unmapped_friend_ids
    #friends.select{|x| x.last_crawled.nil?}
    Rails.logger.info("Populating full friends list")
    Rails.logger.info(friends_list)
    unless num.nil?
      friends_list = friends_list.slice(0,5)
    end

    token ||= authentications[0].access_token

    friends_list.each do |f|
      Resque.enqueue(LoadFriend, self.id, f)
      #friendFb = FbGraph::User.fetch(f.fb_id, :access_token => token)
      #u = User.fromFacebookUserObj(friendFb, true)
    end
  end

  def has_unretrieved_friends
    friends.select{|x| x.last_crawled.nil?}.count > 0
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

  #Generates the next match for the provided person or generates a completely new match set
  #This match is saved!
  #Silently ignores person_id if invalid but, returns nil if unable to generate a match
  def next_match(person_id = nil)
    Rails.logger.info("Matching " + (person_id.nil? ? "nil" : person_id))
    person_a = person_id.nil? ? nil : friends.find(person_id)
    person_a = get_matchable_person if person_a.nil?

    return nil if person_a.nil?

    opposite_gender = (person_a.gender =="male") ? "female" : "male"

    person_b = get_matchable_person(opposite_gender)

    return nil if person_b.nil?

    m = Match.new
    m.status = Match::STATUS[:notselected]
    m.recommender_id = self.id
    m.person_a_id = person_a.id
    m.person_b_id = person_b.id

    Rails.logger.info "Generating match between #{person_a.name} and #{person_b.name}"
    self.push(:matches => m.to_mongo)
    reload # otherwise the collection is dirty/incomplete
    return m
  end

  def photo_url
    return "https://graph.facebook.com/#{fb_id}/picture?type=large"
  end

  protected
    def get_matchable_person(gender = nil)
      if gender.nil?
        matches = User.fields([:id]).where({
            :friend_ids => self.id, 
            :relationship_status => ['Single', nil], 
            :gender => ['male','female']}).all
        return User.find(matches[rand(matches.size)].id)
      else
        matches = User.fields([:id]).where({
            :friend_ids => self.id, 
            :relationship_status => ['Single', nil], 
            :gender => gender}).all
        return User.find(matches[rand(matches.size)].id)
      end

    end

    def youngest_birthdate()
      return 18.years.ago;

    end
end