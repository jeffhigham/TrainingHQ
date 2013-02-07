#!/media/internalcrypt/jeffh/.rvm/bin/ruby 

beginning_time = Time.now
require "./guppy/lib/guppy.rb" 
include Guppy
debug = true
fit_file = "/Volumes/GARMIN/Garmin/Activities/2013-02-06-07-21-14.fit"
file_size = File.stat(fit_file).size/1024
tcx_data = Guppy::DB.open(fit_file)
end_time = Time.now
puts "\nLoaded/Converted \"#{fit_file} (#{file_size}KB)\" in #{(end_time - beginning_time)*1000} ms\n" if debug

beginning_time = Time.now
activities = tcx_data.activities

puts "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n"

puts "\nActivities: #{activities.count}\nLaps: #{activities.first.total_laps}\nTrackpoints: #{activities.first.total_trackpoints}\n"
puts "Activity KJ: #{activities.first.kjoules}\n"
puts "Activity Ride Time: #{activities.first.ride_time}\n"
puts "Activity Total Time: #{activities.first.total_time}\n"
puts "Activity Distance: #{activities.first.distance}\n"
puts "Activity Elevation Gain: #{activities.first.elevation_gain}\n"
puts "Activity Elevation Loss: #{activities.first.elevation_loss}\n"

puts "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n"

end_time = Time.now
puts "Processed \"#{fit_file}\" in #{(end_time - beginning_time)*1000} ms (#{(end_time - beginning_time)}s)\n" if debug
