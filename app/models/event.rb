class Event < ActiveRecord::Base
	has_many :events_user
	has_many :user, :through => :events_user

	belongs_to :user

	has_attached_file :image, style: {medium: "300x300>"}
	validates_attachment_content_type :image, :content_type => /\Aimage\/.*\Z/
end
