FactoryBot.define do
  factory :pergunta do
    texto { "Qual sua avaliação sobre a disciplina?" }
    
    trait :with_template do
      association :template
      formulario_id { nil }
    end
    
    trait :with_formulario do
      association :formulario
      template_id { nil }
      resposta { "Resposta exemplo" } # If storing answers in pergunta table
    end
  end
end