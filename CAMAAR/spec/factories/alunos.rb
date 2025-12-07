FactoryBot.define do
  factory :aluno do
    nome { "Aluno Test" }
    usuario { "aluno_test" }
    email { "aluno@test.com" }
    curso { "Ciência da Computação" }
    matricula { "20230001" }
    departamento { "CC" }
    formacao { "Graduação" }
    ocupacao { "Estudante" }
    registered { true }
    password { "password123" }
    password_confirmation { "password123" }
  end
end