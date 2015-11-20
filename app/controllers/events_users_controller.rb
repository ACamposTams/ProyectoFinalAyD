class EventsUsersController < ApplicationController
  before_action :set_events_user, only: [:show, :edit, :update, :destroy]

  # GET /events_users
  # GET /events_users.json
  def index
    @events_users = EventsUser.all
  end

  # GET /events_users/1
  # GET /events_users/1.json
  def show
  end

  def invite
    @event = Event.find(params[:id])
    # @events_users = @event.eventsusers.new(:user_id => nil)
    # @events_users = @event.events_users.build
    # @users = User.all
    @all_users = User.all.where("users.id != ?", current_user.id)
    # @all_users = User.all.map { |u| [u.id, u.email] }
    # if !params[:user].nil? or !params[:id].nil?
      # unless params[:users][:id].nil? 

      if !params[:users].nil?
        params[:users][:id].each do |u| 
            if !u.empty?
              EventsUser.create(:event_id => @event.id, :user_id => u, :owner => @event.user_id)
            end 
          end
      end
      
    
    # end

    # if User.find(params[:invitee])
    #   @u = User.find(params[:invitee])
    #   @invite = EventsUser.create(:event_id=>@event.id, :user_id=>@u.id, :owner=>@u.id)
    # else
    #   redirect_to @event, notice: "Error"
    # end
    redirect_to @event
  end

  # GET /events_users/new
  def new
    @events_user = EventsUser.new
  end

  # GET /events_users/1/edit
  def edit
  end

  # POST /events_users
  # POST /events_users.json
  def create
    @events_user = EventsUser.new(events_user_params)

    respond_to do |format|
      if @events_user.save
        format.html { redirect_to @events_user, notice: 'Events user was successfully created.' }
        format.json { render :show, status: :created, location: @events_user }
      else
        format.html { render :new }
        format.json { render json: @events_user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /events_users/1
  # PATCH/PUT /events_users/1.json
  def update
    respond_to do |format|
      if @events_user.update(events_user_params)
        format.html { redirect_to @events_user, notice: 'Events user was successfully updated.' }
        format.json { render :show, status: :ok, location: @events_user }
      else
        format.html { render :edit }
        format.json { render json: @events_user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /events_users/1
  # DELETE /events_users/1.json
  def destroy
    @events_user.destroy
    respond_to do |format|
      format.html { redirect_to events_users_url, notice: 'Events user was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_events_user
      @events_user = EventsUser.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def events_user_params
      params[:events_user]
    end
end
