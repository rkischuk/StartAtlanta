class AccountController < ApplicationController
  before_filter :require_authentication#, :except => :index

  def show
    logger.info "Beginning of show"

    #u.populate_likes(current_user.profile.likes)
    #u.populate_groups(current_user.profile.groups)

    @user = current_user.authentications[0]
    @profile = @user.profile

    #current_user.save

    redirect_to :controller => 'matches', :action => 'index'
  end

  def next_match
    render :json => {:user => user}
  end

end
