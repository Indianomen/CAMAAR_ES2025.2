FactoryBot.define do
  factory :administrador do
    sequence(:nome) { |n| "Admin Test #{n}" }
    sequence(:usuario) { |n| "admin_test_#{n}" }
    sequence(:email) { |n| "admin#{n}@test.com" }
    departamento { "TI" }
    formacao { "Mestrado" }
    ocupacao { "Administrador" }
    password { "password123" }
    password_confirmation { "password123" }
  end
end