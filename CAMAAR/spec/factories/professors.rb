FactoryBot.define do
  factory :professor do
    nome { "Professor Test" }
    usuario { "prof_test" }
    email { "prof@test.com" }
    departamento { "Ciência da Computação" }
    formacao { "Doutorado" }
    ocupacao { "Professor" }
    password { "password123" }
    password_confirmation { "password123" }
  end
end