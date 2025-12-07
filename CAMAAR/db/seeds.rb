# Clear existing data
Template.destroy_all
Pergunta.destroy_all
Administrador.destroy_all

puts "🌱 Criando dados de teste..."

# Create an admin
admin = Administrador.create!(
  nome: "Administrador Teste",
  usuario: "admin",
  email: "admin@universidade.edu",
  password: "admin123",
  password_confirmation: "admin123",
  departamento: "TI",
  formacao: "Mestrado",
  ocupacao: "Administrador"
)

puts "✅ Administrador criado: admin / admin123"

# Create some templates
template1 = Template.create!(
  nome: "Avaliação de Disciplina - 2024.1",
  administrador: admin
)

# Add questions to template1
questions1 = [
  "Como você avalia a clareza das explicações do professor?",
  "O material didático foi adequado para o aprendizado?",
  "Como você avalia a dificuldade da disciplina?",
  "A carga horária foi suficiente para os conteúdos?",
  "Quais são suas sugestões para melhorias na disciplina?"
]

questions1.each do |question_text|
  template1.perguntas.create!(texto: question_text)
end

template2 = Template.create!(
  nome: "Avaliação de Laboratório",
  administrador: admin
)

questions2 = [
  "Os equipamentos do laboratório estavam em bom estado?",
  "O técnico do laboratório foi prestativo?",
  "As instruções das práticas foram claras?",
  "O tempo de laboratório foi suficiente?"
]

questions2.each do |question_text|
  template2.perguntas.create!(texto: question_text)
end

puts "✅ Templates criados com perguntas"
puts "🎯 Acesse http://localhost:3000 para ver os templates"