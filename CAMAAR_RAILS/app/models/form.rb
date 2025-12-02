class Form < ApplicationRecord

  belongs_to :administrador
  belongs_to :template
  belongs_to :turma
  
  has_many :perguntas, dependent: :destroy
  
 has_and_belongs_to_many :alunos_respostas, class_name: 'Aluno', join_table: :alunos_formularios
end
