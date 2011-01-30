class AccountController < ApplicationController
  before_filter :require_authentication, :except => :index

  def index
  end

  def show
    logger.info "Beginning of show"

    u = User.find_by_fb_id(current_user.identifier)
    if u.nil?
     u = User.fromFacebookUserObj(current_user, true)
     current_user.user = u
     logger.info "Populating friends list"
     u.populate_friends(current_user.profile.friends)
     u.fetch_and_populate_friend_details(10, current_user.access_token)
    else
      current_user.user = u
    end
     #u.populate_likes(current_user.profile.likes)
     #u.populate_groups(current_user.profile.groups)


    @user = current_user
    @profile = current_user.profile.home

    current_user.save

    ## Other stuff thats WIP:
    #      f = FbGraph::User.fetch(friend.identifier, :access_token => friend.access_token)
    #      r = FbGraph::User.fetch('12811925')
  end
  
  def next_match
    render :json => {:user => current_user.user}
  end

  def loadallfriends
    @u = User.find_by_fb_id(current_user.profile.identifier)
    @count = 0
    @u.friends.where('"users".last_retrieved IS NULL').each do |f|
      friendFb = FbGraph::User.fetch(f.fb_id, :access_token => current_user.access_token)
      u = User.fromFacebookUserObj(friendFb, true)
      @count += 1
    end

  end
end
