require 'authentication'

class ApplicationController < ActionController::Base
  after_filter :delayed_load_data
  include Authentication

  #Commented out, because Facebook messes this up
  #protect_from_forgery

  rescue_from FbGraph::Exception, :with => :fb_graph_exception

  def fb_graph_exception(e)
    flash[:error] = {
     :title   => e.class,
     :message => e.message
    }
    current_user.try(:destroy)
    redirect_to me_url
  end

  private

  def delayed_load_data
    unless current_user.nil? || current_user.user.nil?
      u = current_user.user.nil? ? User.find_by_fb_id(current_user.identifier) : current_user.user
      u.fetch_and_populate_friend_details(5, current_user.access_token) unless u.nil?
    end
  end

end
