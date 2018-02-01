class RemoveSlugFromStudents < ActiveRecord::Migration[5.1]
  def change
    remove_column :students, :slug, :string
  end
end
