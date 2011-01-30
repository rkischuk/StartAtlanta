class UsersController < ApplicationController
  before_filter :require_admin

  def show
    @user = User.find(params[:id])
  end

end
