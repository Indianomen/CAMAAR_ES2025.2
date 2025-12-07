FactoryBot.define do
  factory :template do
    nome { "Template de Avaliação" }
    association :administrador
    
    # Criando template com 3 perguntas como padrao
    transient do
      questions_count { 3 }
    end
    
    after(:create) do |template, evaluator|
      create_list(:pergunta, evaluator.questions_count, template: template)
    end
  end
end