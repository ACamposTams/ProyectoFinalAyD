require 'observer'

class EventsController < ApplicationController
	include Observable
	before_action :find_event, only: [:show, :edit, :update, :destroy, :invite, :setStrategy]
	before_action :authenticate_user!, except: [:index, :show]
	# after_action :create_events_user

	def index
		if params[:tag]
    		@events = Event.tagged_with(params[:tag])
  		else
    		@events = Event.all.order("datetime ASC")
  		end
	end

	def show
		if user_signed_in?
			@user = current_user
			@invites = EventsUser.select("users.*").joins("JOIN users on users.id = events_users.user_id AND events_users.status = 'going'").where("events_users.event_id = ?", params[:id]).uniq
			@assisting = params[:assisting]
			@going  = false
			@eventUser = EventsUser.select("events_users.*").where("events_users.event_id = ? AND events_users.user_id = ?", @event.id, current_user.id).first
			if !@eventUser.nil?
				@assistance = @eventUser.status
				if @assistance == 'going'
					@going = true
				end
			end

			if !@assisting.nil?
				if !@eventUser.nil?
					if @assisting == '1'
						@eventUser.status = 'going'
					else
						@eventUser.status = 'not going'
					end
					@eventUser.save
				else
					@newEventUser = EventsUser.create(:event_id => @event.id, :user_id => current_user.id, :status =>'going')
				end
				redirect_to @event, notice: "Succesfully altered your attendance status"
			end
		end
	end

	def new
		@event = current_user.events.build
		# @all_users = User.all
		# @events_user = @event.eventsuser.build

	end

	def create
		@event = Event.new(ev_params) #current_user.events.build(ev_params)
		@event.user_id = current_user.id

		if @event.valid?
			@event.save
		else
			#@event.error
		end

		#@event.save
		
		if @event.save
			@newUserEvent = EventsUser.create(:event_id=>@event.id, :user_id=>@event.user_id, :owner=>@event.user_id, :status=>'not going')
			@node = Node.create(:node_id => @event.id, :num_vertices=>0)
			#@tagsA = @node.all(select("events.all_tags").joins("JOIN events on event.id = nodes.node_id").where("events.id = ?", @node.id))
			@tagsA = @event.tags #esta es la que deberiamos usar si podemos llamar la funcion tag
			@nodes = Node.all

			@weight = 0

			@nodes.each do |n| 
				if !n.nil?
					@tempEvent = Event.find(n.node_id)

					if @tempEvent.id != @event.id
						@tagsB = @tempEvent.tags # esta es la funcion que deberiamos usar
						#@tagsB = @tempEvent.all(select("events.tags").joins("JOIN events on event.id = nodes.node_id").where("events.id = ?", @tempEvent.id))
						@weight = 0
						@tagsA.each do |tagA|
							@tagsB.each do |tagB|
								if tagA == tagB
									@weight = @weight + 1
								end
							end
						end

						@eventAWords = @event.description.split(" ")
						@eventBWords = @tempEvent.description.split(" ")

						if @weight > 0
							@eventAWords.each do |wordsA|
								@eventBWords.each do |wordsB|
									if wordsA == wordsB
										if wordsA != 'the' || wordsA != 'and' || wordsA != 'a' || wordsA != 'or' || wordsA != 'super' || wordsA != 'fantastic' || wordsA != 'awesome' || wordsA != 'my' || wordsA != 'mine' || wordsA != 'our' || wordsA != 'ours' || wordsA != 'we' || wordsA != 'I'       
											@weight = @weight + 0.3
										end   
									end
								end
							end
						end

						if @weight > 0
							@vertex = Vertex.create(:node_a => @node.id, :node_b => @tempEvent.id, :weight => @weight)
						end

					end
				end
			end

			redirect_to @event, notice: "Succesfully created new event"
		else
			render 'new'
		end
		
		@category = @event.category
		Rails.logger.debug("CATEG: #{@category.inspect}")
		if !@category.nil?
			if @category == "Sports"
				@newEvent = Sport.create(:name => @event.name, :description => @event.description, :user_id => @event.user_id, :datetime => @event.datetime, :location => @event.location)
			elsif @category == "Art and Culture"
				@newEvent = ArtCulture.create(:name => @event.name, :description => @event.description, :user_id => @event.user_id, :datetime => @event.datetime, :location => @event.location)
			elsif @category == "Holiday"
				@newEvent = Holiday.create(:name => @event.name, :description => @event.description, :user_id => @event.user_id, :datetime => @event.datetime, :location => @event.location)
			elsif @category == "Social"
				@newEvent = Social.create(:name => @event.name, :description => @event.description, :user_id => @event.user_id, :datetime => @event.datetime, :location => @event.location)
			elsif @category == "Other"
				@newEvent = Other.create(:name => @event.name, :description => @event.description, :user_id => @event.user_id, :datetime => @event.datetime, :location => @event.location)
			end

			if !@newEvent.nil?
				@newEvent.execute
			end
		end

		@adminLog = Log.instance
		@adminLog.info("User (#{current_user.id}) #{current_user.first_name} created event (#{@event.id}) #{@event.name}")
		@adminLog.write("log.txt")

		add_observer(Notifier.new)
	end

	def invite
		@event = Event.find(params[:id])
		# @events_users = @event.EventsUser.build
		@events_users = @event.EventsUser.build(:user_id => nil)
		# @users = User.all
		@all_users = User.all.where("users.id != ?", current_user.id)
		# @all_users = User.all.map { |u| [u.id, u.email] }
		# if !params[:user].nil? or !params[:id].nil?
			# unless params[:users][:id].nil? 
			params[:user].each do |u| 
				if !u.empty?
					@event.eventsusers.build(:user_id => u)
					# event.add_observer(Notifier.new, func=:informInvitees)
				end 
			end
		redirect_to @event
		# end

		# if User.find(params[:invitee])
		# 	@u = User.find(params[:invitee])
		# 	@invite = EventsUser.create(:event_id=>@event.id, :user_id=>@u.id, :owner=>@u.id)
		# else
		# 	redirect_to @event, notice: "Error"
		# end
	end

	def execute
	end

	def edit
	end

	def update
		if @event.update(ev_params)
			changed
			notify_observers(self, ev_params)
			Rails.logger.debug("NOTIFIED?")
			@vertexes = Vertex.all
			@node = Node.find(@event.id)
			@vertexes.each do |v|
				if v.node_a == @node.id || v.node_b == @node.id
					v.destroy
				end
			end

			redirect_to @event, notice: "Event was succesfully updated"
			@tagsA = @event.tags
			@nodes = Node.all
			@weight = 0

			@nodes.each do |n| 
				@tempEvent = Event.find(n.node_id)
				if @tempEvent.id != @event.id
					@tagsB = @tempEvent.tags # esta es la funcion que deberiamos usar
					#@tagsB = @tempEvent.all(select("events.tags").joins("JOIN events on event.id = nodes.node_id").where("events.id = ?", @tempEvent.id))
					@weight = 0
					@tagsA.each do |tagA|
						@tagsB.each do |tagB|
							if tagA == tagB
								@weight = @weight + 1
							end
						end
					end

					if @weight > 0
						@vertex = Vertex.create(:node_a => @node.id, :node_b => @tempEvent.id, :weight => @weight)
					end
				end
			end
		end
	end

	# def setStrategy
	# 	@strat = params[:option]

	# 	if !@strat.nil?
	# 		if @strat == 'Sports'
	# 			@newEvent = SportsEvent.create()
	# 		elsif @strat == 'Art and Culture'
				
	# 		end
	# 	end

	# 	@newEvent.execute
	# end

	def destroy
		@id = params[:id]
		@node = Node.find(@id)
		
		@adminLog = Log.instance
		@adminLog.info("User (#{current_user.id}) #{current_user.first_name} deleted event (#{@event.id}) #{@event.name}")
		@adminLog.write("log.txt")

		@event.destroy
		@vertexes = Vertex.all

		@vertexes.each do |v|
			if v.node_a == @node.id || v.node_b == @node.id
				v.destroy
			end
		end
		@events_users = EventsUser.all

		@events_users.each do |t|
			if t.event_id == @node.id
				t.destroy
			end
		end
		@node.destroy
		
		redirect_to root_path
	end

	private

	def ev_params
		params.require(:event).permit(:name, :description, :location, :datetime, :all_tags, :image, :category)
	end

	def find_event
		@event = Event.find(params[:id])
		rescue ActiveRecord::RecordNotFound
			redirect_to root_url, notice: 'Event not found'
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
  		Tag.find_by_name!(name).events
	end

end