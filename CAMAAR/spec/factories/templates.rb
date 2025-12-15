FactoryBot.define do
  factory :template do
    nome { "Template de Avaliação" }
    association :administrador
  end

  factory :template_with_questions, parent: :template do
    transient do
      questions_count { 3 }
    end
    
    after(:create) do |template, evaluator|
      create_list(:pergunta, evaluator.questions_count, template: template)
    end
  end
end