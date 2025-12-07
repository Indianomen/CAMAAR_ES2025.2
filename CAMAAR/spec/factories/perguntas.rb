FactoryBot.define do
  factory :pergunta do
    sequence(:texto) { |n| "Como você avalia o aspecto #{n} da disciplina?" }
    association :template
    
    # Formulario opcional para perguntas de template
    formulario { nil }
  end
end