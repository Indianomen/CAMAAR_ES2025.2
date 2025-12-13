FactoryBot.define do
  factory :turma do
    semestre { "2023.2" }
    horario { "Segunda-feira 14:00-16:00" }
    association :professor
    association :disciplina 
  end
end