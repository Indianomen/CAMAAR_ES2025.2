FactoryBot.define do
  factory :pergunta do
    sequence(:texto) { |n| "Como você avalia o aspecto #{n} da disciplina?" }
    association :template
    association :formulario, factory: :formulario
  end
end