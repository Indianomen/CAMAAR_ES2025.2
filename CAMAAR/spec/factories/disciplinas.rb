FactoryBot.define do
  factory :disciplina do
    sequence(:codigo) { |n| "CC#{100 + n}" }
    nome { "Introdução à Programação" }
  end
end