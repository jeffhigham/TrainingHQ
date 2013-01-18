class HrZone < ActiveRecord::Base
  attr_accessible :enabled, :user_id, :z0, :z1, :z2, :z3, :z4, :z5, :z6, :z7

  belongs_to :user

end
