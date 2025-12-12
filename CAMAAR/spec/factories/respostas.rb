FactoryBot.define do
  factory :resposta do
    association :aluno
    association :pergunta
    texto { "Esta é uma resposta de teste" }
  end
end