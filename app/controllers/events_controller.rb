class EventsController < ApplicationController
	before_action :find_event, only: [:show, :edit, :update, :destroy, :invite]
	before_action :authenticate_user!, except: [:index, :show]
	# after_action :create_events_user

	def index
		if params[:tag]
    		@events = Event.tagged_with(params[:tag])
  		else
    		@events = Event.all.order("created_at DESC")
  		end
	end

	def show
		@user = current_user
		@invites = EventsUser.select("users.*").joins("JOIN users on users.id = events_users.user_id").where("events_users.event_id = ?", params[:id])
		# render "events_users/invite"
	end

	def new
		@event = current_user.events.build
		# @all_users = User.all
		# @events_user = @event.eventsuser.build

	end

	def create
		@event = current_user.events.build(ev_params)
		@event.user_id = current_user.id
		@event.save
		
		if @event.save
			@newUserEvent = EventsUser.create(:event_id=>@event.id, :user_id=>@event.user_id, :owner=>@event.user_id)
			@node = Node.create(:node_id => @event.id, :num_vertices=>0)
			#@tagsA = @node.all(select("events.all_tags").joins("JOIN events on event.id = nodes.node_id").where("events.id = ?", @node.id))
			@tagsA = @event.tags #esta es la que deberiamos usar si podemos llamar la funcion tag
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

			redirect_to @event, notice: "Succesfully created new event"
		else
			render 'new'
		end
		
	end

	def invite
		@event = Event.find(params[:id])
		# @events_users = @event.EventsUser.build
		@events_users = @event.EventsUser.build(:user_id => nil)
		# @users = User.all
		@all_users = User.all
		# @all_users = User.all.map { |u| [u.id, u.email] }
		# if !params[:user].nil? or !params[:id].nil?
			# unless params[:users][:id].nil? 
			params[:user].each do |u| 
				if !u.empty?
					@event.eventsusers.build(:user_id => u)
				end 
			end
		
		# end

		# if User.find(params[:invitee])
		# 	@u = User.find(params[:invitee])
		# 	@invite = EventsUser.create(:event_id=>@event.id, :user_id=>@u.id, :owner=>@u.id)
		# else
		# 	redirect_to @event, notice: "Error"
		# end
	end

	def edit
	end

	def update
		if @event.update(ev_params)
			redirect_to @event, notice: "Event was succesfully updated"
		else
			render 'edit'
		end
	end

	def destroy
		@event.destroy
		redirect_to root_path
	end

	private

	def ev_params
		params.require(:event).permit(:name, :description, :location, :datetime, :all_tags, :image)
	end

	def find_event
		@event = Event.find(params[:id])
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
