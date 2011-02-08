class LoadFriends
  @queue = :load_friends

  def self.perform(auth_id)
    Rails.logger.info("Saving friends list")

    auth = Authentication.find(auth_id)
    friend_ids = auth.profile.friends.map{|f| f.identifier}
    User.push_all(auth.user.id, :unmapped_friend_ids => friend_ids)
    Rails.logger.info("Friends list saved")
    User.set(auth.user.id, :friends_list_fetched => true)

    User.find(auth.user.id).fetch_and_populate_friend_details
    Rails.logger.info "Done loading friends"
  end

end