class User < ActiveRecord::Base
  attr_accessible :email, :name, :password

  has_many :power_zones, dependent: :destroy
  has_many :hr_zones, dependent: :destroy

end