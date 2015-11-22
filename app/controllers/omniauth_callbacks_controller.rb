class OmniauthCallbacksController < Devise::OmniauthCallbacksController
 #  def google_oauth2
 #    # @user = User.find_for_google_oauth2(request.env["omniauth.auth"], current_user)

 #    # if @user
 #    #   flash[:notice] = I18n.t "devise.omniauth_callbacks.success", :kind => "Google"
 #    #   sign_in_and_redirect @user, :events => :authentication
 #    # else
 #    #   redirect_to new_user_session_path, notice: 'Access Denied'
 #    # end

 #    client = Google::APIClient.new()
	# client.authorization.access_token = current_user.access_token
	
	# client.authorization.client_id = ENV['GOOGLE_CLIENT_ID']
	# client.authorization.client_secret = ENV['GOOGLE_CLIENT_SECRET']

	# if client.authorization.expired?
	#   client.authorization.fetch_access_token!
	# end

	

 #  end

 def redirect
  google_api_client = Google::APIClient.new({
    application_name: 'TheEvent App',
    application_version: '1.0.0'
  })

  google_api_client.authorization = Signet::OAuth2::Client.new({
    client_id: ENV['GOOGLE_CLIENT_ID'],
    client_secret: ENV['GOOGLE_SECRET_CLIENT'],
    authorization_uri: 'https://accounts.google.com/o/oauth2/auth',
    scope: 'https://www.googleapis.com/auth/calendar.readonly',
    redirect_uri: url_for(:action => :callback)
  })

  authorization_uri = google_api_client.authorization.authorization_uri

  redirect_to authorization_uri.to_s
end

def callback
  google_api_client = Google::APIClient.new({
    application_name: 'TheEvent App',
    application_version: '1.0.0'
  })

  google_api_client.authorization = Signet::OAuth2::Client.new({
    client_id: ENV['GOOGLE_API_CLIENT_ID'],
    client_secret: ENV['GOOGLE_API_CLIENT_SECRET'],
    token_credential_uri: 'https://accounts.google.com/o/oauth2/token',
    redirect_uri: url_for(:action => :callback),
    code: params[:code]
  })

  response = google_api_client.authorization.fetch_access_token!

  session[:access_token] = response['access_token']

  redirect_to url_for(:action => :calendars)
end

def calendars
  google_api_client = Google::APIClient.new({
    application_name: 'TheEvent App',
    application_version: '1.0.0'
  })

  google_api_client.authorization = Signet::OAuth2::Client.new({
    client_id: ENV['GOOGLE_API_CLIENT_ID'],
    client_secret: ENV['GOOGLE_API_CLIENT_SECRET'],
    access_token: session[:access_token]
  })

  google_calendar_api = google_api_client.discovered_api('calendar', 'v3')

  @eventToAdd = {
  	'summary' => 'desc',
  					'location' => 'loc',
  					# 'start' => { 'dateTime' => Chronic.parse('tomorrow 4 pm') },
  					'end' => { 'dateTime' => '2015-05-28T17:00:00-07:00' }
  }

  response = google_api_client.execute({
    api_method: google_calendar_api.events.insert,
    parameters: { 'calendarId' => 'primary' },
	        	:body_object => @eventToAdd,
	          	headers: { 'Content-Type' => 'application/json' }
  })

 
end

end