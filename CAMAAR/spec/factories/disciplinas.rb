FactoryBot.define do
  factory :disciplina do
    sequence(:codigo) { |n| "CC#{1000 + n}" }
    sequence(:nome) { |n| "Disciplina Test #{n}" }
  end
end