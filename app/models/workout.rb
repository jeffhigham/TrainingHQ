class Workout < ActiveRecord::Base
  attr_accessible :name, :datafile
  has_attached_file :datafile
  
end