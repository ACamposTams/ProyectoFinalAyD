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
			@search = Event.select("events.*").where(["name LIKE ?", "%#{@search_name}%"])
		end
	end
end
