FactoryBot.define do
  factory :administrador do
    nome { "Admin Test" }
    usuario { "admin_test" }
    email { "admin@test.com" }
    departamento { "TI" }
    formacao { "Mestrado" }
    ocupacao { "Administrador" }
    password { "password123" }
    password_confirmation { "password123" }
  end
end