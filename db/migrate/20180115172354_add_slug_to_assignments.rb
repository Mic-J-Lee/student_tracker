class AddSlugToAssignments < ActiveRecord::Migration[5.1]
  def change
    add_column :assignments, :slug, :string, after: :id
  end
end
