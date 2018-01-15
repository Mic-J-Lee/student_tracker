class CreateAssignments < ActiveRecord::Migration[5.1]
  def change
    create_table :assignments do |t|
      t.references :student

      t.string :repo_name
      t.string :completion

      t.timestamps
    end
  end
end
