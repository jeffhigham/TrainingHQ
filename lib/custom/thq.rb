# Based on Guppy.
require 'nokogiri'
require 'time'

require File.join(File.dirname(__FILE__), 'thq', 'tcx_parser')
require File.join(File.dirname(__FILE__), 'thq', 'gpx_parser')
require File.join(File.dirname(__FILE__), 'thq', 'fit_parser')
require File.join(File.dirname(__FILE__), 'thq', 'datafile')
require File.join(File.dirname(__FILE__), 'thq', 'activity')
require File.join(File.dirname(__FILE__), 'thq', 'track_point')
require File.join(File.dirname(__FILE__), 'thq', 'lap')

module THQ

	TCX = 'tcx'
  GPX = 'gpx'
  FIT = 'fit'
  SRM = 'srm'

	def self.version
		"0.0.1"
	end

end
