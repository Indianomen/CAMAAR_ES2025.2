class Turma < ApplicationRecord
  # Relationships
  belongs_to :professor
  belongs_to :disciplina
  belongs_to :formulario, optional: true
  
  has_and_belongs_to_many :alunos, join_table: :alunos_turmas
  #
  # Validations
  validates :semestre, presence: true
  validates :horario, presence: true
  validates :professor_id, presence: true
  validates :disciplina_id, presence: true
  
  def full_description
    "#{disciplina.nome} (#{disciplina.codigo}) - #{professor.nome} - #{semestre} - #{horario}"
  end
  
  def simple_description
    "#{disciplina.codigo} - #{professor.nome} - #{semestre}"
  end
end