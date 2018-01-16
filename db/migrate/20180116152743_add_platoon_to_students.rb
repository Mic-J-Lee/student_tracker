class AddPlatoonToStudents < ActiveRecord::Migration[5.1]
  def change
    add_column :students, :platoon, :string
  end
end
