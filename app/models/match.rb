class Match
  include MongoMapper::EmbeddedDocument
  plugin MongoMapper::Plugins::Timestamps 

  belongs_to :user

  key :status, String
  belongs_to :person_a, :class_name =>"User"
  key :person_a_id, ObjectId
  belongs_to :person_b, :class_name => "User"
  key :person_b_id, ObjectId
  belongs_to :recommender, :class_name => "User"
  key :recommender_id, ObjectId
  belongs_to :skipped_user, :class_name => "User"
  key :skipped_user_id, ObjectId

  timestamps!

  STATUS = {
    :notselected => 0,
    :yes => 1,
    :no => 2,
    :skip => 3
  }

  def respondable_by(user)
    if status.nil? || status != STATUS[:notselected]
      if user == recommender
        return true
      end
    end
    
    return false
  end

  # Given an id of 1 person in the match, returns the other person
  def matchee identifier
    identifier = BSON::ObjectId(identifier) unless identifier.is_a?(BSON::ObjectId)
    if (person_a_id == identifier) || (person_b_id == identifier)
      return (person_a_id == identifier) ? person_b : person_a
    else
      return nil
    end
  end

  def self.find identifier
    identifier = BSON::ObjectId(identifier) unless identifier.is_a?(BSON::ObjectId)
    u = User.first('matches._id' => identifier)
    if u.nil?
      return nil
    else
      return u.matches.find(identifier)
    end
  end

end

