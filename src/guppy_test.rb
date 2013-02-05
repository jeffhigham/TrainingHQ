#!/media/internalcrypt/jeffh/.rvm/bin/ruby 


require "~/Sites/rails/TrainingHQ/lib/guppy/lib/guppy.rb" 
include Guppy

test_file = "./guppytestfile.tcx"
file_size = File.stat(test_file).size/1024
debug = true

beginning_time = Time.now
tcx_data = Guppy::DB.open(test_file)
end_time = Time.now
puts "\nLoaded \"#{test_file} (#{file_size}KB)\" in #{(end_time - beginning_time)*1000} milliseconds\n" if debug

beginning_time = Time.now
activities = tcx_data.activities

puts "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n"

puts "\nActivities: #{activities.count}\nLaps: #{activities.first.total_laps}\nTrackpoints: #{activities.first.total_trackpoints}\n"
puts "Activity KJ: #{activities.first.kjoules}\n"
puts "Activity Ride Time: #{activities.first.ride_time}\n"
puts "Activity Total Time: #{activities.first.total_time}\n"
puts "Activity Distance: #{activities.first.distance}\n"

puts "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n"

end_time = Time.now
puts "Processed \"#{test_file}\" in #{(end_time - beginning_time)*1000} milliseconds\n" if debug

