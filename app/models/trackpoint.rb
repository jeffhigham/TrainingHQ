class Trackpoint < ActiveRecord::Base
  attr_accessible :altitudemeters, :cadence, :distancemeters, :heartratebpm, :latitudedegrees, :longitudedegrees, :time, :watts
  belongs_to :lap
end
