class Trackpoint < ActiveRecord::Base
  attr_accessible :altitude, :cadence, :distance, :heart_rate, :latitude, :longitude, :time, :watts
  belongs_to :lap
end
