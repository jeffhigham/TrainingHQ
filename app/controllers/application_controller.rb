class ApplicationController < ActionController::Base
	before_filter :check_login, :except => [:login, :update_activity_queue_realtime ]
  protect_from_forgery
  #force_ssl
  
	private
		def current_user
  		@current_user ||= User.find(session[:user_id]) if session[:user_id]
		end
	helper_method :current_user

		def check_login
			unless current_user
				redirect_to login_url, notice: "Please log in"
			end
		end
end