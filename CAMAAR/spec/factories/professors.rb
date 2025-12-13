FactoryBot.define do
  factory :professor do
    sequence(:nome) { |n| "Professor Test #{n}" }
    sequence(:usuario) { |n| "prof_test_#{n}" }
    sequence(:email) { |n| "prof#{n}@test.com" }
    departamento { "Departamento Test" }
    formacao { "Doutorado" }
    ocupacao { "Professor" }
    password { "password123" }
    password_confirmation { "password123" }
    registered { true }
  end
end