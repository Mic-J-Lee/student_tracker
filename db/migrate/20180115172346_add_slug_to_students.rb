class AddSlugToStudents < ActiveRecord::Migration[5.1]
  def change
    add_column :students, :slug, :string, after: :id
  end
end
