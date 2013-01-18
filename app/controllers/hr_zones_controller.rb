class HrZonesController < ApplicationController
  # GET /hr_zones
  # GET /hr_zones.json
  def index
    @hr_zones = HrZone.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @hr_zones }
    end
  end

  # GET /hr_zones/1
  # GET /hr_zones/1.json
  def show
    @hr_zone = HrZone.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @hr_zone }
    end
  end

  # GET /hr_zones/new
  # GET /hr_zones/new.json
  def new
    @hr_zone = HrZone.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @hr_zone }
    end
  end

  # GET /hr_zones/1/edit
  def edit
    @hr_zone = HrZone.find(params[:id])
  end

  # POST /hr_zones
  # POST /hr_zones.json
  def create
    @hr_zone = HrZone.new(params[:hr_zone])

    respond_to do |format|
      if @hr_zone.save
        format.html { redirect_to @hr_zone, notice: 'Hr zone was successfully created.' }
        format.json { render json: @hr_zone, status: :created, location: @hr_zone }
      else
        format.html { render action: "new" }
        format.json { render json: @hr_zone.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /hr_zones/1
  # PUT /hr_zones/1.json
  def update
    @hr_zone = HrZone.find(params[:id])

    respond_to do |format|
      if @hr_zone.update_attributes(params[:hr_zone])
        format.html { redirect_to @hr_zone, notice: 'Hr zone was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @hr_zone.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /hr_zones/1
  # DELETE /hr_zones/1.json
  def destroy
    @hr_zone = HrZone.find(params[:id])
    @hr_zone.destroy

    respond_to do |format|
      format.html { redirect_to hr_zones_url }
      format.json { head :no_content }
    end
  end
end
