class Tag < ActiveRecord::Base
	has_many :taggings
	has_many :events, :through => :taggings
	has_many :users, :through => :taggings

	validates :name, length: { minimum: 2 }
end
