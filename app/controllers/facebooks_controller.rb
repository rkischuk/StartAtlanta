class FacebooksController < ApplicationController
  before_filter :require_authentication, :only => :destroy

  # handle Facebook Auth Cookie generated by JavaScript SDK
  def show
    auth = Authentication.auth.from_cookie(cookies)
    authenticate Authentication.identify(auth.user)
    redirect_to Facebook.config[:app_url]
  end

  # handle Normal OAuth flow: start
  def new
    next_url = AppConfig.facebook_app_url + "facebook/callback"
    #next_url += ("?request_ids=" + params[:request_ids]) unless params[:request_ids].nil?
    @auth_url = Authentication.auth.client.web_server.authorize_url(
      :redirect_uri => next_url, :scope => AppConfig.facebook_perms
    )
  end

  def create # /facebook/callback
    next_url = AppConfig.facebook_app_url + "facebook/callback"
    #next_url += ("?request_ids=" + session[:request_ids]) unless session[:request_ids].nil?
    access_token = Authentication.auth.client.web_server.get_access_token(
      params[:code],
      :redirect_uri => next_url #AppConfig.facebook_app_url + "facebook/callback"
    )
    logger.info("Access token is " + access_token.to_json)
    fb_user = FbGraph::User.me(access_token.token).fetch
    auth = Authentication.identify(fb_user)
    authenticate auth.user
    auth.user.fromFacebookUserObj(fb_user) # saves state within this method

    #
    # TODO: Figure out why the user is nil when coming in to view matches
    #

    if auth.user.unmapped_friend_ids.empty? # New user
      Resque.enqueue(LoadFriends, auth.id)
    end
    
    if session[:request_ids].nil? #normal user
      redirect_to AppConfig.facebook_app_url
    else # incoming match request
      redirect_to matches_view_url + "?request_ids=" + session[:request_ids]
    end
  end

  def destroy
    unauthenticate
    redirect_to root_url
  end

end