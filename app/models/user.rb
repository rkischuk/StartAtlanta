class User < ActiveRecord::Base

  has_many :matches1, :class_name => "Match", :foreign_key => 'match_id1'
  has_many :matches2, :class_name => "Match", :foreign_key => 'match_id2'
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

  def next_match( user_id )
    #generate match object from users friends
    #try to do this only for friends who have retrieved data already
    match = Match.new
  end

end
