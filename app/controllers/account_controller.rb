class AccountController < ApplicationController
  before_filter :require_authentication, :except => :index

  def index
    
  end

  def show
    @posts = current_user.profile.home
  end

end