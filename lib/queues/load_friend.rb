class LoadFriend
  @queue = :load_friend

  def self.perform(user_id, friend_fb_id )
    u = User.find(user_id)
    u.populate_friend(friend_fb_id)
    #u = User.populate_from_facebook(friend_fb_id, auth_token)
  end
  
end