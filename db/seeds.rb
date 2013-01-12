# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

require './src/guppy/lib/guppy.rb'

datafile = "./src/2013-01-09-11-53-04-formated.tcx"

db = Guppy::Db.open(datafile)
db.activities.each do |activity|
  
  puts activity.date
  puts activity.sport
  puts

	new_activity = Activity.create(
		sport: activity.sport,
		activityid: activity.date
  	)

  activity.laps.each do |lap|
  	puts "Lap Time: #{lap.time}"
  	puts "Lap Distance: #{lap.distance}"
  	puts "Lap Max Speed: #{lap.max_speed}"
  	puts "Lap Calories: #{lap.calories}"
  	puts "Lap Avg Heart Rate: #{lap.average_heart_rate}"
  	puts "Lap Max Heart Rate: #{lap.max_heart_rate}"
  	puts "Lap Avg Watts: #{lap.average_watts}"
  	puts "Lap Avg Cadence: #{lap.average_cadence}"
  	puts "Lap Intensity: #{lap.intensity}"
	puts

	new_lap = new_activity.laps.create(
			totaltimeseconds: lap.time,
			distancemeters: lap.distance,
			maximumspeed: lap.max_speed,
			calories: lap.calories,
			averageheartratebpm: lap.average_heart_rate,
			maximumheartratebpm: lap.max_heart_rate,
			avgwatts: lap.average_watts,
			cadence: lap.average_cadence,
			intensity: lap.intensity

		)



  	lap.track_points.each do |track_point|
  		#puts "\t\tTrackpoint: #{track_point.time}"
    	#puts "\t\tLatitude: #{track_point.latitude}"
  		#puts "\t\tLongitude: #{track_point.longitude}"
  		#puts "\t\tCadence: #{track_point.cadence}"
  		#puts "\t\tWatts: #{track_point.watts}\n\n"

  		new_trackpoint = new_lap.trackpoints.create(
  				time: track_point.time,
  				latitudedegrees: track_point.latitude,
  				longitudedegrees: track_point.longitude,
  				cadence: track_point.cadence,
  				watts: track_point.watts
  			)
  	end

  end

end