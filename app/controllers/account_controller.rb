class AccountController < ApplicationController
  before_filter :require_authentication, :except => :index

  def index
  end

  def next_match
    
  end

  def show

     u = User.fromFacebookUserObj(current_user)

     friends = current_user.profile.friends

     # Takes too long to do entire list
     friends = friends.slice(0..20)

     friends.each do |friend|
        User.fromFacebookUserObj(friend)
     end

    @user = current_user
    @profile = current_user.profile.home

    ## Other stuff thats WIP:
    #      f = FbGraph::User.fetch(friend.identifier, :access_token => friend.access_token)
    #      r = FbGraph::User.fetch('12811925')
  end
end
