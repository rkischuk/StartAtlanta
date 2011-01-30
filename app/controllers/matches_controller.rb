class MatchesController < ApplicationController

  def index
    
  end

  def show
    if (params['previous_match_id'])
      match = Match.find(params['previous_match_id'])
      if match.respondable_by(current_user.user)
        match.status = Match::STATUS[params['previous_match_response'].to_sym]
        match.skipped_user_id = params['skipped_user_id']
        logger.info match.status
        match.save
      end
    end

    render :json => {"error" => current_user}

  end
  
  private
  
  def user_info_for(user)
    return {:name => user[:name], :fb_id => user['fb_id'], :id => user['id']}
  end

end
