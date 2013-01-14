class Activity < ActiveRecord::Base
  attr_accessible :activityid, :creator_name, :product_id, :sport, :unit_id, :datafile, :author_name, :activity_date
  has_attached_file :datafile
  has_many :laps, dependent: :destroy


  def max_watts
  	max_watts = 0
  	self.laps.each do |lap|
  		max_watts = lap.max_watts unless lap.max_watts < max_watts
  	end
  	return max_watts
  end

  def min_watts
  	min_watts = 10000 # something way too high.
  	self.laps.each do |lap|
  		min_watts = lap.min_watts unless lap.min_watts > min_watts
  	end
  	return min_watts
  end

  def ave_watts
  	bunch_of_watts = []
  	self.laps.each do |lap|
  		bunch_of_watts << lap.ave_watts
  	end
  	return (bunch_of_watts.sum/bunch_of_watts.count)
  end

	def crunch_uploaded_file(datafile)
		require './src/guppy/lib/guppy.rb'
		#datafile = "./src/2013-01-09-11-53-04-formated.tcx"
		db = Guppy::Db.open(datafile)

		db.activities.each do |activity|
  	
  	new_activity = Activity.create(
    	activity_date: activity.activity_date,
			sport: activity.sport,
			activityid: activity.id,
    	creator_name: activity.creator_name,
    	unit_id: activity.unit_id,
    	product_id: activity.product_id,
    	author_name: activity.author_name,
  	)

  	activity.laps.each do |lap|
  	new_lap = new_activity.laps.create(
			total_time: lap.time,
			distance: lap.distance,
			max_speed: lap.max_speed,
			calories: lap.calories,
			ave_heart_rate: lap.ave_heart_rate,
			max_heart_rate: lap.max_heart_rate,
			ave_watts: lap.ave_watts,
			ave_cadence: lap.ave_cadence,
	 	  intensity: lap.intensity
		)


    bunch_of_track_points = []
  	lap.track_points.each do |track_point|
  		this_track_point = {
         time: track_point.time,
         latitude: track_point.latitude,
         longitude: track_point.longitude,
         cadence: track_point.cadence,
         watts: track_point.watts,
         heart_rate: track_point.heart_rate,
         altitude: track_point.altitude,
         distance: track_point.distance
      }

      bunch_of_track_points << this_track_point
  	end
    new_lap.trackpoints.create(bunch_of_track_points)
  	end
		end
	end

end