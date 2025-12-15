FactoryBot.define do
  factory :formulario do
    association :administrador
    association :template
    association :turma
    
    after(:create) do |formulario|
      formulario.template.perguntas.each do |pergunta_template|
        create(:pergunta, 
               template: formulario.template, 
               formulario: formulario, 
               texto: pergunta_template.texto)
      end
    end
  end
end