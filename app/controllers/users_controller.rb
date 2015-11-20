class UsersController < ApplicationController
	# skip_before_filter :search, only: :show, :invites
	skip_before_filter :invites, only: :show

	def show
		@user = current_user

		# search

		@personalRec = Array.new()
		@events = Event.all
		@i = 0

		if !@user.nil?
			@user_tags = @user.tags
			
			@events.each do |e|	
				@eventTags = e.tags
				@user_tags.each do |ut|
					
					@eventTags.each do |et|
						if (et.id == ut.id) && @personalRec.index(e).nil?
							@personalRec[@i] = e
							@i = @i +1
						end
					end
				end
			end
		end

	end

	def search
		@search_name = params[:search]

		if @search_name == ""
			@search = Event.all
		else
			@search = Event.select("events.*").joins("JOIN taggings ON taggings.event_id = events.id JOIN tags ON tags.id = taggings.tag_id").where(["events.name LIKE ? OR tags.name LIKE ?", "%#{@search_name}%",  "%#{@search_name}%"]).uniq
		end
		Rails.logger.debug("My object: #{@search.inspect}")

		@recommendation = Array.new()
		@shown = Array.new()
		@search.each do |e|
			@shown[@shown.size] = e.id
		end
		@i = 0
		@repeat = false

		@search.each do |e|
			@eventVertices = Vertex.select("vertices.*").where(["node_a = ? OR node_b = ?", e.id, e.id])
			@eventVertices.each do |ev|
				if !ev.nil?
					@node = ev.node_a
					if @node == e.id
						@event = Event.find(ev.node_b)
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
								@recommendation[@i] = @event
								@shown[@shown.size] = @event.id
								@i = @i + 1
							end
						end
					else
						@event = Event.find(@node)
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
									@recommendation[@i] = @event
									@shown[@shown.size] = @event.id
									@i = @i + 1
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
