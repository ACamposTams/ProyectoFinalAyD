class EventsController < ApplicationController
	before_action :find_event, only: [:show, :edit, :update, :destroy]
	# after_action :create_events_user

	def index
		@events = Event.all.order("created_at DESC")
	end

	def show
	end

	def new
		@event = current_user.events.build

	end

	def create
		@event = current_user.events.build(ev_params)

		# @eventOwner = EventsUser.new(params[:user_id => current_user.user_id, :event_id => @event.event_id])
		# EventsUser.insert("events_users").params()
		# @eventUser = EventsUser.build(:user_id => @event.user_id, :event_id => @event.event_id)
		# @eventUser.save
		# EventsUser.create!(:user_id => :user_id)
		if @event.save
			redirect_to @event, notice: "Succesfully created new event"
		else
			render 'new'
		end
	end

	def create_events_user
		# EventsUser.create!(params[event.id].merge(owner: => :event_id))
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
