class PowerZone < ActiveRecord::Base
  attr_accessible :enabled, :user_id, :z0, :z1, :z2, :z3, :z4, :z5, :z6, :z7, :ftp
  belongs_to :user
  after_initialize :zero_all_attrs
	require "./lib/shared_methods.rb"
  include SharedMethods

  @@percent_attributes = [ :z1_percent, :z2_percent, :z3_percent, 
  							   				 :z4_percent, :z5_percent, :z6_percent ]
  @@time_attributes =	[ :z1_time, :z2_time, :z3_time, 
  							    		:z4_time, :z5_time, :z6_time ]

	attr_accessor *@@percent_attributes, *@@time_attributes
  
  def zero_all_attrs
      @@percent_attributes.each do |a|
        instance_variable_set "@#{a}", 0
      end
      @@time_attributes.each do |a|
        instance_variable_set "@#{a}", 0
      end
  end
  
  def set_zones_for(activity)
  	percent_dist = { z1: 0, z2: 0, z3: 0, 
  									 z4: 0, z5: 0, z6: 0 }

  	last_time = 0
  	elapsed_time = 0
  	activity.laps.each do |lap|
  		lap.trackpoints.each do |track_point|
  			
  			last_time=Time.parse(track_point.time) if last_time == 0

  			elapsed_time = elapsed(Time.parse(track_point.time),last_time)
  			case track_point.watts
					when self.z1..self.z2-1
  						percent_dist[:z1] += 1
  						@z1_time += elapsed_time
  				when self.z2..self.z3-1
  						percent_dist[:z2] += 1
  						@z2_time += elapsed_time
  				when self.z3..self.z4-1
  						percent_dist[:z3] += 1
  						@z3_time += elapsed_time
  				when self.z4..self.z5-1
  						percent_dist[:z4] += 1
  						@z4_time += elapsed_time
  				when self.z5..self.z6-1
  						percent_dist[:z5] += 1
  						@z5_time += elapsed_time
  				else
  						percent_dist[:z6] += 1
  						@z6_time += elapsed_time
  			end
  			last_time = Time.parse(track_point.time)
  		end
  	end

  	percent_dist.each_pair do |k,v|
  		instance_variable_set "@#{k}_percent", (v/activity.total_trackpoints.to_f*100).round(2)	
		end
		@@time_attributes.each do |a|
        instance_variable_set "@#{a}", time_formatted(instance_variable_get("@#{a}").to_i)
    end
  end
  
end
