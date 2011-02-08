class Authentication
  include MongoMapper::Document
  belongs_to :user

  key :identifier, String
  key :access_token, String
  key :user_id, ObjectId

  def profile
    @profile ||= FbGraph::User.me(self.access_token).fetch
  end

  def self.auth
    FbGraph::Auth.new AppConfig.facebook_client_id, AppConfig.facebook_client_secret
  end

  def self.identify(fb_user)
    _fb_user_ = find_or_initialize_by_identifier(fb_user.identifier.try(:to_s))
    _fb_user_.access_token = fb_user.access_token.token
    _fb_user_.save!
    _fb_user_
  end

end