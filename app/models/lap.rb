class Lap < ActiveRecord::Base
  attr_accessible :ave_heart_rate, :ave_watts, :ave_cadence, :calories, :distance, :intensity, :max_heart_rate, :max_speed, :start_time, :total_time

  belongs_to :activity
  has_many :trackpoints, dependent: :destroy
end
