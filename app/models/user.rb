class User < ActiveRecord::Base
  RELATIONSHIP = {
    :single => "not married"
  }

  has_many :matches1, :class_name => "Match", :foreign_key => 'person_a'
  has_many :matches2, :class_name => "Match", :foreign_key => 'person_b'
  has_many :recommendations, :class_name => "Match", :foreign_key => 'recommender_id'
  has_many :skipped, :class_name => "Match", :foreign_key => 'skipped_user_id'
  has_and_belongs_to_many :likes, :join_table => "users_likes"

  # from: http://railscasts.com/episodes/163-self-referential-association

  has_many :friendships
  has_many :friends, :through => :friendships
  has_many :inverse_friendships, :class_name => "Friendship", :foreign_key => "friend_id"
  has_many :inverse_friends, :through => :inverse_friendships, :source => :user

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
    #Silently ignores person_id if invalid

    person_a person.nil? ? nil : friends.first(:person_id => person_id)

    unless person_a
      person_a = get_matchable_person
    end

    person_b = find_match_for_user(person_a)

      person_b = find_match_for_user(person)

    gender = 'male'
    #if can't find a person_b, loop through with a new person_a, first male, then female
    while person_b.nil?
      if person_a.nil?
        person_a = get_matchable_person(gender, skiplist)

        #just exit if no more person_a to find
        break if person_a.nil? && gender=='female'
        gender = 'female' if person_a.nil?
      end
      unless person_a.nil?
        person_b = find_match_for_user(person_a)
        skiplist << person_a
      end
    end

    unless person_a.nil?
      if person_a.gender=='female'
        person_a,person_b = person_b,person_a
      end
    end

    Match.new(:person_a => person_a, :person_b => person_b)
  end

  protected
    def get_matchable_person(gender = nil)
      # > 18
      # 2) relationship_status = "not married"

      #friends.where(
      #friends.where("age > 18 and gender = ? and relationship_status = 'single'", gender)

    end
end
