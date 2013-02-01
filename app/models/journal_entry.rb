class JournalEntry < ActiveRecord::Base
  attr_accessible :body, :category, :subject, :user_id
  belongs_to :user
end
