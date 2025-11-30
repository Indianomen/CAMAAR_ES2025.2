class CreateQuestions < ActiveRecord::Migration[8.0]
  def change
    create_table :questions do |t|
      t.integer :form_ID
      t.integer :template_ID
      t.string :texto
      t.string :resposta

      t.timestamps
    end
  end
end
