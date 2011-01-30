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

    target_user = params['user_id']
    match = current_user.user.next_match( target_user.nil? ? target_user : nil )

    response = [user_info_for(match.person_b)]
    unless target_user
      response << user_info_for(match.person_a)
    end

    render :json => { "match_id" => match.id, "users" => response }
  end
  
  private
  
  def user_info_for(user)
    return {:name => user[:name], :fb_id => user['fb_id'], :id => user['id']}
  end

end
