module Auth

  class Unauthorized < StandardError; end

  def self.included(base)
    base.send(:include, Auth::HelperMethods)
    base.send(:include, Auth::ControllerMethods)
  end

  module HelperMethods

    def current_user
      @current_user ||= Authentication.find(session[:current_user])
    rescue ActiveRecord::RecordNotFound
      nil
    end

    def authenticated?
      !current_user.blank?
    end

  end

  module ControllerMethods

    def require_authentication
      Rails.logger.info "Requiring auth for user: " + session[:current_user].to_s
      authenticate Authentication.find(session[:current_user])
    rescue Unauthorized => e
      redirect_to new_facebook_url and return false
    end

    def authenticate(user)
      raise Unauthorized unless user
      session[:current_user] = user.id
    end

    def unauthenticate
      current_user.destroy
      @current_user = session[:current_user] = nil
    end

  end

end