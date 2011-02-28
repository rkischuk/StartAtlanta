class MatchesController < ApplicationController

  before_filter :require_friends, :except => [:waiting, :view]

  def index
    
  end

  def show
    if (params['previous_match_id'])
      match = current_user.matches.find(params['previous_match_id'])

      if !match.nil? and match.respondable_by(current_user)
        match.status = Match::STATUS[params['previous_match_response'].to_sym]
        match.skipped_user_id = params['skipped_user_id']
        logger.info match.status
        match.save
      end
    end

    if current_user
      target_user = params['user_id']
      match = current_user.next_match( target_user.nil? ? nil : target_user )

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

  def ready
    current_user.reload
    render :json => { "ready_to_match" => current_user.friends_list_fetched? }
  end

  def require_friends
    if current_user.unmapped_friend_ids.empty? # New user
      redirect_to matches_waiting_url
    end
  end

  def view

    request_id = params[:request_ids]

    @request = FbGraph::Request.fetch(request_id, :access_token => current_user.authentications[0].access_token)

    params = @request.data.split '='
    @request.destroy
    @match = Match.find(params[1])
  end
  
  private
  
  def user_info_for(user)
    return {:name => user.name, :fb_id => user.fb_id, :id => user.id}
  end

end