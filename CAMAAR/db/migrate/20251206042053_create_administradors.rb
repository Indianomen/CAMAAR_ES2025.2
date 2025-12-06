class CreateAdministradors < ActiveRecord::Migration[8.0]
  def change
    create_table :administradors do |t|
      t.string :nome
      t.string :departamento
      t.string :formacao
      t.string :usuario
      t.string :email
      t.string :ocupacao
      t.string :password_digest

      t.timestamps
    end
  end
end
