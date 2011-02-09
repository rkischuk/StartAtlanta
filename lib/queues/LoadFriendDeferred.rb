# Lower priority queue to load friend info
class LoadFriendDeferred < LoadFriend
  @queue = :load_friend_deferred
end