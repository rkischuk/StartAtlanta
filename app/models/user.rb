class User < ActiveRecord::Base
  has_many :matches1, :class_name => "Match", :foreign_key => 'match_id1'
  has_many :matches2, :class_name => "Match", :foreign_key => 'match_id2'
  has_many :recommendations, :class_name => "Match", :foreign_key => 'recommender_id'
  has_and_belongs_to_many :likes
end
