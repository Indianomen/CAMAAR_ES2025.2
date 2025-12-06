class Formulario < ApplicationRecord
  # Relationships
  belongs_to :administrador
  belongs_to :template
  belongs_to :turma
  
  has_many :perguntas, dependent: :destroy
  has_many :respostas, dependent: :destroy
  
  has_and_belongs_to_many :alunos_respostas, 
                          class_name: 'Aluno', 
                          join_table: :alunos_formularios
  
  # Validations
  validates :administrador_id, presence: true
  validates :template_id, presence: true
  validates :turma_id, presence: true
  
  # Scopes
  scope :pendentes_para_aluno, ->(aluno_id) {
    joins(turma: :alunos)
    .where(alunos: { id: aluno_id })
    .where.not(id: Aluno.find(aluno_id).formularios_respostas.pluck(:id))
  }
end