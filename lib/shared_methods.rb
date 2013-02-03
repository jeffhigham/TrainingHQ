
module SharedMethods

	def ride_distance_formatted(distance_in_feet)
		return distance_in_feet/5280.to_f
	end

	def time_formatted(time_in_seconds)
	    
	    hours = time_in_seconds/3600.to_i
	    minutes = (time_in_seconds/60 - hours * 60).to_i
	    seconds = (time_in_seconds - (minutes * 60 + hours * 3600))

	    return sprintf("%02d:%02d:%02d\n", hours, minutes, seconds)
	end

	def distance_meters_to_feet(meters)
	  return (meters * 3.281).round(1)	
	end

	def altitude_meters_to_feet(altitude)
	  return (altitude * 3.281).round(1)
	end

end