class AccountController < ApplicationController
  before_filter :require_authentication, :except => :index

  def index
  end

  def show

     u = User.fromFacebookUserObj(current_user)
     current_user.user = u

     friends = current_user.profile.friends

     # Takes too long to do entire list
     #friends = friends.slice(0..20)

     friends.each do |friend|
        logger.info(ActiveSupport::JSON.encode(friend))
        f = User.fromFacebookUserObj(friend)
        u.friendships.build(:friend_id => f.id)
        u.save
     end

    @user = current_user
    @profile = current_user.profile.home
    @friendships = u.friendships

    current_user.save

    ## Other stuff thats WIP:
    #      f = FbGraph::User.fetch(friend.identifier, :access_token => friend.access_token)
    #      r = FbGraph::User.fetch('12811925')
  end
  
  def next_match
    render :json => {:user => current_user.user}
  end
end
