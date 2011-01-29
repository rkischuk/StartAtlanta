class AccountController < ApplicationController
  before_filter :require_authentication, :except => :index

  def index
    
  end

  def show
    @posts = current_user.profile.home
    @user = current_user
  end

end