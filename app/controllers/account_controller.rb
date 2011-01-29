class AccountController < ApplicationController
  before_filter :require_authentication, :except => :index

  def index
    
  end

  def show
    @user = current_user
  end

end
