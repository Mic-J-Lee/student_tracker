class CreateAttendanceRecords < ActiveRecord::Migration[5.1]
  def change
    create_table :attendance_records do |t|
      t.datetime :date
      t.references :student, foreign_key: true
      t.string :description

      t.timestamps
    end
  end
end
