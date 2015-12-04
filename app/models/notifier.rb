class Notifier < ActiveRecord::Base
	def update(event, info)
    	puts "#{event.name} has changed its time to #{info}."
    	Rails.logger.debug("DEGUBBING NOTIFIER")
	end

	def informInvitees(event, info)
		puts "#{event.name} has changed its time to #{info}."
	end
end
