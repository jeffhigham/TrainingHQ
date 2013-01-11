class Lap < ActiveRecord::Base
  attr_accessible :averageheartratebpm, :avgwatts, :cadence, :calories, :distancemeters, :intensity, :maximumheartratebpm, :maximumspeed, :starttime, :totaltimeseconds

  belongs_to :activity
  has_many :trackpoints, dependent: :destroy
end
