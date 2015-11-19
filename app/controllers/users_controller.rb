class UsersController < ApplicationController
	skip_before_filter :search, only: :show
	def show
		@user = current_user
		search
	end

	def search
		@search_name = params[:search]

		if @search_name == ""
			@search = Event.all
		else
			@search = Event.select("events.*").joins("JOIN taggings ON taggings.event_id = events.id JOIN tags ON tags.id = taggings.tag_id").where(["events.name LIKE ? OR tags.name LIKE ?", "%#{@search_name}%",  "%#{@search_name}%"])
		end
		Rails.logger.debug("My object: #{@search.inspect}")
		# @similarEvents = Event.select("events.*").where(["tags LIKE ?", "%#{@search_name}%"])

		@recommendation = Array.new(10)
		@i = 0

		@search.each do |e|
			@eventVertices = Vertex.select("vertices.*").where(["node_a = ? OR node_b = ?", e.id, e.id])

			@eventVertices.each do |ev|
			# @tempEvent = Vertex.where(["node_a = ? OR node_b = ?", e.id, e.id]).first
				if !ev.nil?
					@node = ev.node_a
					# @node = Vertex.select("vertices.node_a").where("node_b = ?", e.id)
					if @node == e.id
						@event = Event.find(ev.node_b)

						if !@event.nil?
							@recommendation[@i] = @event
							@i = @i + 1
						end
						
					else
						@event = Event.find(@node)
						if !@event.nil?
							@recommendation[@i] = @event
							@i = @i + 1
						end
					end
				end
			end	
		end
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
