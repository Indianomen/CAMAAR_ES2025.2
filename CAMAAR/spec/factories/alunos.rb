FactoryBot.define do
  factory :aluno do
    sequence(:nome) { |n| "Aluno Test #{n}" }
    sequence(:usuario) { |n| "aluno_test_#{n}" }
    sequence(:email) { |n| "aluno#{n}@test.com" }
    curso { "Ciência da Computação" }
    sequence(:matricula) { |n| "2023000#{n}" }
    departamento { "CC" }
    formacao { "Graduação" }
    ocupacao { "Estudante" }
    registered { true }
    password { "password123" }
    password_confirmation { "password123" }
  end
end