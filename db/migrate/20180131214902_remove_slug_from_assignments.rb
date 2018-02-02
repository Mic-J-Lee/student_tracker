class RemoveSlugFromAssignments < ActiveRecord::Migration[5.1]
  def change
    remove_column :assignments, :slug, :string
  end
end
