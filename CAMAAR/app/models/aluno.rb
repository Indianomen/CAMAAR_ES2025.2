class Aluno < ApplicationRecord
  has_secure_password
  
  # Validations
  validates :password, length: { minimum: 6 }, if: -> { password.present? }
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
    # A form is pending if it was sent to the student but has NO responses from them
    # We need to check for actual Resposta records, not the formularios_respostas association
    formularios_com_resposta = Formulario.joins(:perguntas => :respostas)
                                         .where(respostas: { aluno_id: id })
                                         .distinct
                                         .pluck(:id)
    
    formularios.where.not(id: formularios_com_resposta)
  end
end