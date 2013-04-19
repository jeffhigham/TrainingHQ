class ObjectStore < ActiveRecord::Base
  attr_accessible :name, :payload
  serialize :payload, Array
end
