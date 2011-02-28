class Like
  include MongoMapper::Document

  ensure_index 'fb_id'

  key :fb_id, String
  key :name, String
  key :category, String
  key :link, String

end
