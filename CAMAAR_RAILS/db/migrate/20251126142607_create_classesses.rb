class CreateClassesses < ActiveRecord::Migration[8.0]
  def change
    create_table :classesses do |t|
      t.integer :professor_ID
      t.integer :disciplina_ID
      t.integer :form_ID
      t.string :semestre
      t.string :time

      t.timestamps
    end
  end
end
