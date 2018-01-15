class Assignment < ApplicationRecord
  extend FriendlyId
  friendly_id :repo_name

  belongs_to :student
end
