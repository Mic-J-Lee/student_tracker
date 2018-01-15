class Student < ApplicationRecord
  extend FriendlyId
  friendly_id :github_handle

  has_many :assignments
end



