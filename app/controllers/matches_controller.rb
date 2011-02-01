class MatchesController < ApplicationController

  def index
    
  end

  def show
    if (params['previous_match_id'])
      match = Match.where(:id => params['previous_match_id']).first
      if !match.nil? and match.respondable_by(current_user.user)
        match.status = Match::STATUS[params['previous_match_response'].to_sym]
        match.skipped_user_id = params['skipped_user_id']
        logger.info match.status
        match.save
      end
    end

    if current_user
      target_user = params['user_id']
      match = current_user.user.next_match( target_user.nil? ? nil : target_user )

      if match.nil?
        render :json => {"error" => "NO_MATCHES"}
      else
        response = [user_info_for(match.person_b)]
        unless target_user
          response << user_info_for(match.person_a)
        end
        render :json => { "match_id" => match.id, "users" => response }
      end
    else
      render :json => {"error" => "User does not have an active session"}
    end
  end
  
  def view
    
  end
  
  private
  
  def user_info_for(user)
    return {:name => user[:name], :fb_id => user['fb_id'], :id => user['id']}
  end

end
