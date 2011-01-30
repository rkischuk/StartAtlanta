class MatchesController < ApplicationController
  def show
    if (params['previous_match_id'])
      match = Match.find(params['previous_match_id'])
      match.response = params['previous_match_response']
      match.save
    end

    match = current_user.user.next_match( params['user_id'] ? params['user_id'] : nil )

    render :json => match #u.collect{|user| {:name => user['name'], \
        #:fb_id => user['fb_id'], :id => user['id']}}
      #render :json => u
  end
end
