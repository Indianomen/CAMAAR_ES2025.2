class CreateForms < ActiveRecord::Migration[8.0]
  def change
    create_table :forms do |t|
      t.integer :administrator_ID
      t.integer :template_ID
      t.integer :turma_ID

      t.timestamps
    end
  end
end
