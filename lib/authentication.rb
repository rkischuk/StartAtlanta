module Authentication

  class Unauthorized < StandardError; end

  def self.included(base)
    base.send(:include, Authentication::HelperMethods)
    base.send(:include, Authentication::ControllerMethods)
  end

  module HelperMethods

    def current_user
      @current_user ||= Facebook.find(session[:current_user])
    rescue ActiveRecord::RecordNotFound
      nil
    end

    def authenticated?
      !current_user.blank?
    end

  end

  module ControllerMethods

    def require_authentication
      Rails.logger.info "Checking auth"
      authenticate Facebook.find_by_id(session[:current_user])
    rescue Unauthorized => e
      Rails.logger.info "USer is not authenticated"
      redirect_to root_url and return false
    end

    def require_admin
      Rails.logger.info(session[:current_user_fb_id])
    end

    def authenticate(user)
      raise Unauthorized unless user
      session[:current_user] = user.id
      #session[:current_user_fb_id] = user.identifier
    end

    def unauthenticate
      current_user.destroy
      @current_user = session[:current_user] = nil
    end

  end

end