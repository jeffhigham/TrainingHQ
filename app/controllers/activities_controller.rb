class ActivitiesController < ApplicationController
  
  # status of the activity queue for AJAX requests.
  def show_activity_queue
    @pending_activities = Activity.where(:processed => 0).order('created_at')
    respond_to do |format|
      format.js
    end
  end

  def hide_activity_queue
    respond_to do |format|
      format.js
    end
  end

  def update_activity_queue_realtime
    @pending_activities = Activity.where(:processed => 0).order('created_at')
    respond_to do |format|
      format.js
    end
  end

  # GET /activities
  # GET /activities.json
  def index
    @user = current_user
    @activities = Activity.where({processed: 1, user_id: current_user.id}).order('activity_date')
    @new_activities = Activity.where({processed: 0, user_id: current_user.id}).order('activity_date')
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @activities }
    end
  end

  def show
    @activity = Activity.find(params[:id])
    @user = current_user
   # @javascript_data = @activity.javascript_data
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @activity }
    end
  end

  def summary # tabular summary
    @activity = Activity.find(params[:id])
    respond_to do |format|
      format.js
    end
  end

  def map # map and graph data
    @activity = Activity.find(params[:id])
    respond_to do |format|
      format.js
    end
  end

  def graph_data
    @activity = Activity.find(params[:id])
   # @trackpoint_data = @activity.get_trackpoint_data
    @user_power_zones = current_user.power_zones.where(:enabled => true).first
    @user_hr_zones = current_user.hr_zones.where(:enabled => true).first
    respond_to do |format|
      format.js
    end
  end

  def load_trackpoint
    @activity = Activity.find(params[:id])
    @trackpoint_data = @activity.get_trackpoint_data
    respond_to do |format|
      format.js
      format.json
    end
  end

  # GET /activities/new
  # GET /activities/new.json
  def new
    @activity = Activity.new
    respond_to do |format|
      format.html # new.html.erb
      format.js
      format.json { render json: @activity }
    end
  end

  def cancel_new
    respond_to do |format|
      format.js
    end
  end

  # GET /activities/1/edit
  def edit
    @activity = Activity.find(params[:id])
  end

  # POST /activities
  # POST /activities.json
  def create
    @activity = Activity.new(params[:activity])
    @activity[:user_id] = current_user.id

    respond_to do |format|
      if @activity.save
        format.html { redirect_to activities_path, notice: 'Activity was successfully created.' }
        format.json { render json: @activity, status: :created, location: @activity }
      else
        format.html { render action: "new" }
        format.json { render json: @activity.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /activities/1
  # PUT /activities/1.json
  def update
    @activity = Activity.find(params[:id])

    respond_to do |format|
      if @activity.update_attributes(params[:activity])
        format.html { redirect_to current_user, notice: 'Activity was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @activity.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /activities/1
  # DELETE /activities/1.json
  def destroy
    @activity = Activity.find(params[:id])
    @activity.destroy
    respond_to do |format|
      format.html { redirect_to activities_url }
      format.js { 
                  @pending_activities = Activity.where(:processed => 0).order('created_at')
                  render action: "show_activity_queue"
                }
      format.json { head :no_content }
    end
  end
end
