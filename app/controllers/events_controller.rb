class EventsController < ApplicationController
	before_action :find_event, only: [:show, :edit, :update, :destroy, :invite]
	before_action :authenticate_user!, except: [:index, :show]
	# after_action :create_events_user

	def index
		@events = Event.all.order("created_at DESC")
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
		params.require(:event).permit(:name, :description, :image, :location, :datetime)
	end

	def find_event
		@event = Event.find(params[:id])
	end
end
