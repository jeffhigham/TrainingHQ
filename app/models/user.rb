class User < ActiveRecord::Base
  attr_accessible :email, :name, :password, :password_confirmation, :avatar
  has_secure_password
  has_attached_file :avatar, :styles => { :medium => "300x300>", :thumb => "100x100>" }

  email_regex = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

	validates :name, 	:presence => true , 
										:length => { :maximum => 20 }
	validates :email, :presence => true,
										:format => { :with => email_regex },
										:uniqueness => { :case_sensitive => false }
	
	validates_presence_of :password, :on => :create

  has_many :activities, dependent: :destroy
  has_many :power_zones, dependent: :destroy
  has_many :hr_zones, dependent: :destroy
  has_many :journal_entries, dependent: :destroy

  require "./lib/shared_methods.rb"
  include SharedMethods

end