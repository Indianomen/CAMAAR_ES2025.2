class CreateTemplates < ActiveRecord::Migration[8.0]
  def change
    create_table :templates do |t|
      t.integer :administrator_ID
      t.string :name

      t.timestamps
    end
  end
end
