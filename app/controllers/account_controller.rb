class AccountController < ApplicationController
  before_filter :require_authentication

  def show
    @user = current_user.authentications[0]
    @profile = @user.profile

    if params[:request_ids].nil?
      redirect_to :controller => 'matches', :action => 'index'
    else
      redirect_to matches_view_url + '?request_ids=' + params[:request_ids]
    end
  end

  def next_match
    render :json => {:user => user}
  end

end