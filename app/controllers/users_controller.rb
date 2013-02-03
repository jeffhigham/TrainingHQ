class UsersController < ApplicationController
  skip_before_filter :check_login, :only => [ :new, :create ]
  # GET /users
  # GET /users.json

  def activity_queue_status
    @pending_activities = @user.activities.where(:processed => 0).order('created_at')
    respond_to do |format|
      format.html { render  'activity_queue_dynamic', :layout => false }
    end
  end

  def index
    @users = User.all
    respond_to do |format|
      format.html  # index.html.erb
      format.json { render json: @users }
    end
  end

  # GET /users/1
  # GET /users/1.json
  def show
    @user = current_user || User.find(params[:id])
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
        format.html { redirect_to users_path, notice: 'User was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @user.errors, status: :unprocessable_entity }
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
