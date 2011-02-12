class LoadFriends
  @queue = :load_friends

  def self.perform(auth_id)
    Rails.logger.info("Saving friends list")

    auth = Authentication.find(auth_id)
    friends  = auth.profile.friends(:access_token => auth.access_token, \
        :fields => 'id,name,gender,relationship_status,about')
    friend_ids = friends.map{|f| f.identifier}

    User.push_all(auth.user.id, :unmapped_friend_ids => friend_ids)

    friends.each do |friend|
        u = User.find_by_fb_id(friend.identifier)
        u ||= User.new
        u.populate_from_fbUser(friend)

        auth.user.add_to_set({:friend_ids => u.id})
        u.add_to_set({:friend_ids => auth.user.id})
    end
    User.set(auth.user.id, :friends_list_fetched => true)

    User.find(auth.user.id).fetch_and_populate_friend_details
    Rails.logger.info "Done loading friends"
  end

end