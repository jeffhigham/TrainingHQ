
module SharedMethods

	def time_formatted(time_in_seconds)
	    
	    hours = time_in_seconds/3600.to_i
	    minutes = (time_in_seconds/60 - hours * 60).to_i
	    seconds = (time_in_seconds - (minutes * 60 + hours * 3600))

	    if hours == 0 # 
	    	return sprintf("%02d:%02d", minutes, seconds)
	    else
	    	return sprintf("%02d:%02d:%02d", hours, minutes, seconds)
	    end
	end

	def distance_meters_to_feet(distance_in_meters)
	  (distance_in_meters * 3.281).round(1)	
	end

	def distance_meters_to_miles(distance_in_meters)
			(distance_in_meters/1609.34).to_f.round(1)
	end

	def altitude_meters_to_feet(altitude_in_meters)
	  (altitude_in_meters * 3.281).to_f.round(1)
	end

	def speed_kmph_to_mph(speed_kmph)
		(speed_kmph / 1.60934 ).to_f.round(3)
	end

	def elapsed(current_thing,past_thing)
      current_thing - past_thing
  end

end