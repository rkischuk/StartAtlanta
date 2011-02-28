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
      next_url = new_facebook_url
      if params["request_ids"].nil?
          session[:request_ids] = nil
      else
          session[:request_ids] = params[:request_ids]
      end
      #next_url += ("?request_ids=" + params["request_ids"]) unless params["request_ids"].nil?
      redirect_to next_url and return false
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