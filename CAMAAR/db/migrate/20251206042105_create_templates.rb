class CreateTemplates < ActiveRecord::Migration[8.0]
  def change
    create_table :templates do |t|
      t.references :administrador, null: false, foreign_key: true
      t.string :nome

      t.timestamps
    end
  end
end
