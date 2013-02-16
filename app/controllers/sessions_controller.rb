class SessionsController < ApplicationController
  skip_before_filter :check_login

  def new
  end

  def create
    user = User.find_by_email(params[:email])
    if user && user.authenticate(params[:password])
      session[:user_id] = user.id
      if user.is_admin?
        redirect_to users_path, :notice => "Logged in as an Admin!"
      else
        redirect_to user_activities_path(user), :notice => "Logged in as a regular Joe!"
      end
    else
      redirect_to login_path, :notice => "Invalid email or password"
    end
  end

  def destroy
    session[:user_id] = nil
    redirect_to login_path, :notice => "Logged out!"
  end
end