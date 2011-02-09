module Auth

  class Unauthorized < StandardError; end

  def self.included(base)
    base.send(:include, Auth::HelperMethods)
    base.send(:include, Auth::ControllerMethods)
  end

  module HelperMethods

    def current_user
      user = User.find(session[:current_user])
      unless user.nil?
        @current_user ||= user
      end
    end

    def authenticated?
      !current_user.blank?
    end
  end

  module ControllerMethods

    def require_authentication
      authenticate User.find(session[:current_user].to_s)
      #Rails.logger.info "Require auth - authorized"
    rescue Unauthorized => e
      Rails.logger.info "Require auth - unauthorized"
      redirect_to new_facebook_url and return false
    end

    def authenticate(user)
      Rails.logger.info "Testing authentication"
      raise Unauthorized unless user
      Rails.logger.info "Authenticated"
      #Rails.logger.info "Setting session user to " + user.id.to_s
      session[:current_user] = user.id
    end

    def unauthenticate
      current_user.destroy
      @current_user = session[:current_user] = nil
    end
  end

end