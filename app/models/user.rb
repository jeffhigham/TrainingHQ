class User < ActiveRecord::Base
  attr_accessible :email, :name, :password, :avatar

  has_attached_file :avatar, :styles => { :medium => "300x300>", :thumb => "100x100>" }

  has_many :activities, dependent: :destroy
  has_many :power_zones, dependent: :destroy
  has_many :hr_zones, dependent: :destroy

end