class Aluno < ApplicationRecord
  has_secure_password
  
  # Validations
  validates :nome, presence: true
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :matricula, presence: true, uniqueness: true
  validates :usuario, presence: true, uniqueness: true
  validates :curso, presence: true
  validates :departamento, presence: true
  
  # Relationships
  has_and_belongs_to_many :turmas, join_table: :alunos_turmas
  has_and_belongs_to_many :formularios_respostas, 
                          class_name: 'Formulario', 
                          join_table: :alunos_formularios
  has_many :respostas, dependent: :destroy
  
  # Helper methods
  def formularios
    Formulario.joins(turma: :alunos).where(alunos: { id: id })
  end
  
  def formularios_pendentes
    formularios.where.not(id: formularios_respostas.pluck(:id))
  end
end