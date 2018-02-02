class Student < ApplicationRecord
  has_many :assignments
  has_many :attendance_records
end
