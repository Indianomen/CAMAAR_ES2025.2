FactoryBot.define do
  factory :resposta do
    texto { "Resposta de teste" }
    association :aluno
    association :pergunta
    association :formulario
  end
end