class AddRegisteredToProfessors < ActiveRecord::Migration[8.0]
  def change
    add_column :professors, :registered, :boolean
  end
end
