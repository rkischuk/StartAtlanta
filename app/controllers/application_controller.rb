require 'auth'

class ApplicationController < ActionController::Base
  before_filter :capture_app_request

  #after_filter :delayed_load_data
  include Auth

  rescue_from FbGraph::Exception, :with => :fb_graph_exception

  def fb_graph_exception(e)
    flash[:error] = {
     :title   => e.class,
     :message => e.message
    }
    logger.error(e.class.to_s + " - " + e.message )
    current_user.try(:destroy)
    redirect_to matches_show_url
  end

  private

  def capture_app_request
    unless params[:request_ids].nil?
      session[:request_ids] = params[:request_ids]
    end
  end

  def delayed_load_data
    unless current_user.nil?
      current_user.fetch_and_populate_friend_details(5, current_user.access_token)
    end
  end

end
