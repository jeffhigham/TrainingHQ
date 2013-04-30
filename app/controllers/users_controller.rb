class UsersController < ApplicationController
  skip_before_filter :check_login, :only => [ :new, :create ]
  # GET /users
  # GET /users.json

  def index
    if current_user.is_admin?
      @users = User.all
      respond_to do |format|
        format.html  # index.html.erb
        format.json { render json: @users }
      end
    else
        #redirect_to user_path(current_user), :notice => "Non-admins are denied access to user list."
        redirect_to user_activities_path(user)
    end
  end

  # GET /users/1
  # GET /users/1.json
  def show
    @user = User.find(params[:id])
    @activities = @user.activities.where(:processed => 1).order('activity_date')
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @user }
    end
  end

  # GET /users/new
  # GET /users/new.json
  def new
    @user = User.new

    respond_to do |format|
      format.html
      format.js
      format.json { render json: @user }
    end
  end

  # GET /users/1/edit
  def edit
    @user = User.find(params[:id])
    respond_to do |format|
      format.js
    end
  end

  def hide_edit
    respond_to do |format|
      format.js
    end
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(params[:user])

    respond_to do |format|
      if @user.save
        @users = User.all
        @the_new_user = @user
        #format.html { redirect_to users_path, notice: 'User was successfully created.' }
        format.js
        format.json { render json: users_path, status: :created, location: @user }
      else
        # http://www.alfajango.com/blog/rails-3-remote-links-and-forms/
        format.html { render action: "new" }
        format.js 
      end
    end
  end

  # PUT /users/1
  # PUT /users/1.json
  def update
    @user = User.find(params[:id])

    respond_to do |format|
      if @user.update_attributes(params[:user])
       # format.html { redirect_to user_path(@user), notice: 'Your user profile has been successfully updated!' }
       # format.json { head :no_content }
       format.js
      else
        #format.html { render action: "edit" }
        #format.json { render json: @user.errors, status: :unprocessable_entity }
        format.js
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user = User.find(params[:id])
    @user.destroy
    @users = User.all
    respond_to do |format|
      format.html { redirect_to users_url }
      format.js
      format.json { head :no_content }
    end
  end
end
