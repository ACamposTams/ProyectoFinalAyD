class EventsUser < ActiveRecord::Base
	# has_and_belongs_to_many :user
	# has_and_belongs_to_many :event
	belongs_to :user
	belongs_to :event
end
