class Activity < ActiveRecord::Base
  attr_accessible :activityid, :creatorname, :productid, :sport, :unitid, :datafile
  has_attached_file :datafile

end
