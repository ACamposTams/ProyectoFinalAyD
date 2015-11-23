class UsersController < ApplicationController
	skip_before_filter :search, only: :show
	# skip_before_filter :invites, only: :show
	#before_action :show, only: :invite

	def show
		@user = current_user
		@personalRec = Array.new()
		@events = Event.all
		@invitedTo = EventsUser.all.where("user_id = ?", current_user.id).uniq
		@repeat = false

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
					@vertices = Vertex.select("vertices.*").where(["node_a = ? OR node_b = ?", e.event_id, e.event_id]).order(weight: :desc)
					@vertices.each do |v|
						if @i == 10
							break
						else
							if !v.nil?
								@node = v.node_a
								if @node == e.event_id
									@event = Event.find(v.node_b)
								else
									@event = Event.find(@node)
								end

								@personalRec.each do |p|
									if p.id == @event.id || p.user_id == current_user.id
										@repeat = true
										break
									end
								end

								if !@event.nil?
									if @repeat == false && @event.user_id != current_user.id
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
		# @user = current_user
		# @personalRec = Array.new()
		# @events = Event.all
		# @invitedTo = EventsUser.all.where("user_id = ? AND status = 'not going'", current_user.id)
		# repeat = false

		# if !@user.nil?
		# 	if @invitedTo.nil?
		# 		@user_tags = @user.tags
		# 		@events.each do |e|
		# 			@eventTags = e.tags
		# 			@user_tags.each do |ut|
		# 				@eventTags.each do |et|
		# 					if (et.id == ut.id) && @personalRec.index(e).nil?
		# 						@personalRec[@personalRec.size] = e
		# 					end
		# 				end
		# 			end
		# 		end
		# 	else
		# 		@i = 0
		# 		@invitedTo.each do |e|
		# 			@vertices = Vertex.select("vertices.*").where(["node_a = ? OR node_b = ?", e.id, e.id]).order(weight: :desc)
		# 			@vertices.each do |v|
		# 				if @i==10
		# 					break
		# 				else
		# 					if !v.nil?
		# 						@node = v.node_a
		# 						if @node == e.id
		# 							@event = Event.find(e.node_b)
		# 						else
		# 							@event = Event.find(@node)
		# 						end
		# 						if !@event.nil? && @event.user_id != @user.id
		# 							#if @repeat == false
		# 								@personalRec[@personalRec.size] = @event
		# 								@i = @i + 1
		# 							#end
		# 						end
		# 					end
		# 				end
		# 			end
		# 		end
		# 		@user_tags = @user.tags
		# 		@events.each do |e|
		# 			@eventTags = e.tags
		# 			@user_tags.each do |ut|
		# 				@eventTags.each do |et|
		# 					@invited = EventsUser.select("events_users.*").where(["event_id = ? AND user_id = ?", e.id, @user.id]).uniq
		# 					if (et.id == ut.id) && @personalRec.index(e).nil? && e.user_id != @user.id && @invited.nil? 
		# 						@personalRec[@personalRec.size] = e
		# 					end
		# 				end
		# 			end
		# 		end
		# 	end
		# end
	end

	def search
		@search_name = params[:search]
		@search = Array.new()

		if @search_name == ""
			@search = Event.all
		else
			@search_name = @search_name.split(" ")
			@search_name.each do |s|
				@search = Event.select("events.*").joins("JOIN taggings ON taggings.event_id = events.id JOIN tags ON tags.id = taggings.tag_id").where(["events.name LIKE ? OR tags.name LIKE ?", "%#{s}%",  "%#{s}%"]).uniq
			end
		end
		Rails.logger.debug("SEARCHSEARCH: #{@search.inspect}")

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
									if @repeat == false && @event.user_id != current_user.id
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
		@events = Event.select("events_users.*").joins("JOIN events_users ON events_users.event_id = events.id").where("events_users.owner = ?", current_user.id).uniq
		Rails.logger.debug("USEREVENTSS: #{@sumInvites.inspect}")
	end

	def invites 
		@invites = EventsUser.select("events_users.*").where("events_users.user_id = ?", current_user.id).uniq
		@myInvites = Array.new()
		@invites.each do |i|
			if i.owner != current_user.id
				@event = Event.select("events.*").where("events.id = ?", i.event_id)
				@event.each do |e|
					@myInvites[@myInvites.size] = e
				end
			end
		end
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