class UsersController < ApplicationController
	skip_before_filter :search, only: :show
	# skip_before_filter :invites, only: :show
	#before_action :show, only: :invite

	def show
		@user = current_user
		@personalRec = Array.new()
		@events = Event.all
		@invitedTo = EventsUser.all.where("user_id = ?", current_user.id)

		if !@user.nil?
			if @invitedTo.nil?
				@user_tags = @user.tags
				@events.each do |e|	
					@eventTags = e.tags
					@user_tags.each do |ut|
						
						@eventTags.each do |et|
							if (et.id == ut.id) && @personalRec.index(e).nil?
								@personalRec[@personalRec.size] = e
							end
						end
					end
				end
			else
				@i = 0
				@invitedTo.each do |e|
					@vertices = Vertex.select("vertices.*").where(["node_a = ? OR node_b = ?", e.id, e.id]).order(weight: :desc)
					@vertices.each do |v|
						if @i == 10
							break
						else
							if !v.nil?
								@node = v.node_a
								if @node == e.id
									@event = Event.find(e.node_b)
								else
									@event = Event.find(@node)
								end

								if !@event.nil?
									if @repeat == false
										@personalRec[@personalRec.size] = @event
										@i = @i +1
									end
								end

							end
						end
					end
				end
			end

		end

	end

	def search
		@search_name = params[:search]
		@search_name = @search_name.split(" ")
		Rails.logger.debug("SEARCHNAME: #{@search_name.inspect}")
		@search = Array.new()

		if @search_name == ""
			@search = Event.all
		else
			@search_name.each do |s|
				@search = Event.select("events.*").joins("JOIN taggings ON taggings.event_id = events.id JOIN tags ON tags.id = taggings.tag_id").where(["events.name LIKE ? OR tags.name LIKE ?", "%#{s}%",  "%#{s}%"]).uniq
			end
		end

		@safe_net = Event.all
		if @search != @safe_net.size
			@recommendation = Array.new()
			@shown = Array.new()
			@search.each do |e|
				@shown[@shown.size] = e.id
			end
			@repeat = false
			@i = 0

			@search.each do |e|
				if @shown.size == @safe_net.size
					break
				else
					@eventVertices = Vertex.select("vertices.*").where(["node_a = ? OR node_b = ?", e.id, e.id]).order(weight: :desc)
					@eventVertices.each do |ev|
						if !ev.nil?
							if @i == 10
								break
							else
								@node = ev.node_a
								if @node == e.id
									@event = Event.find(ev.node_b)
								else
									@event = Event.find(@node)
								end

								if !@event.nil?
									@shown.each do |r|
										if !r.nil?
											if r == @event.id
												@repeat = true
												break
											else
												@repeat = false
											end
										end
									end
									if @repeat == false
										@recommendation[@recommendation.size] = @event
										@shown[@shown.size] = @event.id
										@i = @i +1
									end
								end
							end
						end
					end	
				end
			end
		end

		# @search.each do |s|
		# 	@recommendation.each do |r|
		# 		if !r.nil? 
		# 			if r.id = s.id
		# 				@recommendation.delete(r)
		# 			end
		# 		end
		# 	end
		# end
		# @events = Event.all

		# @events.each do |e|
		# 	@eventTags = e.tags

		# 	@eventTags.each do |t|
		# 		if t == @search_name
		# 			@similarEvent = true
		# 		end
		# 	end
		# end
	end

	def stats
		@events = Event.select("events.*, events_users.*").joins("JOIN events_users ON events_users.event_id = events.id").where("events_users.owner = ?", current_user.id).uniq
		# @userEvents = Event.select("events_users.*").joins("JOIN users ON users.id = events.user_id JOIN events_users ON events_users.user_id = users.id").where("events_users.event_id = ?", e.id).uniq

		# @events.each do |e|
		# 	@sumInvites = EventsUser.where("event_id = ? AND owner != ?", e.id, current_user.id).count 
		# 	@sumGoing =  EventsUser.where("event_id = ? AND owner != ? AND status = ?", e.id, current_user.id, 'going').count
		# 	@sumI[@sumI.size] = @sumInvites
		# 	@sumG[@sumG.size] = @sumGoing
		# end


		Rails.logger.debug("USEREVENTSS: #{@sumInvites.inspect}")
	end

	def invites 
		@invites = Event.select("events.*").joins("JOIN events_users ON events.id = events_users.event_id").where("events_users.user_id = ? AND events_users.owner != ?", current_user.id, current_user.id).uniq
	end

	def all_tags=(names)
  		self.tags = names.split(",").map do |name|
      		Tag.where(name: name.strip).first_or_create!
  		end
	end

	def all_tags
  		self.tags.map(&:name).join(", ")
	end

	def self.tagged_with(name)
  		Tag.find_by_name!(name).users
	end
end
