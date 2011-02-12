class FacebooksController < ApplicationController
  before_filter :require_authentication, :only => :destroy

  # handle Facebook Auth Cookie generated by JavaScript SDK
  def show
    #logger.info "SHOW"
    auth = Authentication.auth.from_cookie(cookies)
    authenticate Authentication.identify(auth.user)
    redirect_to Facebook.config[:app_url]
  end

  # handle Normal OAuth flow: start
  def new
    #logger.info "NEW"
    @auth_url = Authentication.auth.client.web_server.authorize_url(
        :redirect_uri => AppConfig.facebook_app_url + "facebook/callback",
        :scope => AppConfig.facebook_perms
      )
  end

  # /facebook/callback
  def create
    Rails.logger.info AppConfig.facebook_app_url + "facebook/callback" + "?"
    Rails.logger.info  params[:code]
    access_token = Authentication.auth.client.web_server.get_access_token(
      params[:code],
      :redirect_uri => AppConfig.facebook_app_url + "facebook/callback"
    )
    fb_user = FbGraph::User.me(access_token).fetch
    auth = Authentication.identify(fb_user)

    authenticate auth.user
    # saves state within this method
    auth.user.fromFacebookUserObj(fb_user)

    if auth.user.unmapped_friend_ids.empty?
      Resque.enqueue(LoadFriends, auth.id)
    end

    redirect_to AppConfig.facebook_app_url
  end

  def destroy
    unauthenticate
    redirect_to root_url
  end

end