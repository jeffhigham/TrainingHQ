class PowerZonesController < ApplicationController
  # GET /power_zones
  # GET /power_zones.json
  def index
    #@power_zones = PowerZone.all
    @power_zones = PowerZone.where(:user_id => current_user.id)

    respond_to do |format|
      format.html # index.html.erb
      format.js
      format.json { render json: @power_zones }
    end
  end

  # GET /power_zones/1
  # GET /power_zones/1.json
  def show
    @power_zone = PowerZone.find(params[:id])
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @power_zone }
    end
  end

  # GET /power_zones/new
  # GET /power_zones/new.json
  def new
    @power_zones = PowerZone.where(:user_id => current_user.id)
    @power_zone = PowerZone.new
    respond_to do |format|
      format.html # new.html.erb
      format.js
      format.json { render json: @power_zone }
    end
  end

  # GET /power_zones/1/edit
  def edit
    @power_zone = PowerZone.find(params[:id])
  end

  # POST /power_zones
  # POST /power_zones.json
  def create
    @power_zone = PowerZone.new(params[:power_zone])
    @power_zone.user_id=current_user.id
    respond_to do |format|
      if @power_zone.save
        @power_zones = PowerZone.where(:user_id => current_user.id)
        #format.html { redirect_to user_path(@power_zone.user), notice: 'Power zone was successfully created.' }
        format.js  { render action: "index" }
        #format.json { render json: @power_zone, status: :created, location: @power_zone }
      else
        format.html { render action: "new" }
        format.json { render json: @power_zone.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /power_zones/1
  # PUT /power_zones/1.json
  def update
    @power_zone = PowerZone.find(params[:id])

    respond_to do |format|
      if @power_zone.update_attributes(params[:power_zone])
         @power_zones = PowerZone.where(:user_id => current_user.id)
        #format.html { redirect_to @power_zone, notice: 'Power zone was successfully updated.' }
        format.js  { render action: "index" }
        #format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @power_zone.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /power_zones/1
  # DELETE /power_zones/1.json
  def destroy
    @power_zone = PowerZone.find(params[:id])
    @power_zone.destroy
    @power_zones = PowerZone.where(:user_id => current_user.id)
    respond_to do |format|
      #format.html { user_path(@power_zone.user_id) }
      format.js  { render action: "index" }
      #format.json { head :no_content }
    end
  end
end
