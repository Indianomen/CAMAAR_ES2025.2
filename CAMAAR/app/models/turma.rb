##
# Representa uma turma em que uma disciplina é ministrada por um professor.
#
# Cada turma pode estar associada a um formulário específico para coleta
# de respostas dos alunos.
#
class Turma < ApplicationRecord
  ##
  # Professor responsável pela turma.
  #
  # @return [Professor]
  #
  belongs_to :professor

  ##
  # Disciplina que está sendo ministrada na turma.
  #
  # @return [Disciplina]
  #
  belongs_to :disciplina

  ##
  # Formulário associado a esta turma (opcional).
  #
  # @return [Formulario, nil]
  #
  belongs_to :formulario, optional: true

  ##
  # Alunos matriculados na turma.
  #
  # @return [ActiveRecord::Associations::CollectionProxy<Aluno>]
  #
  has_and_belongs_to_many :alunos, join_table: :alunos_turmas

  ##
  # Semestre em que a turma está sendo ofertada.
  #
  validates :semestre, presence: true

  ##
  # Horário das aulas da turma.
  #
  validates :horario, presence: true

  ##
  # Valida presença do professor.
  #
  validates :professor_id, presence: true

  ##
  # Valida presença da disciplina.
  #
  validates :disciplina_id, presence: true

  ##
  # Retorna uma descrição completa da turma, incluindo disciplina,
  # código, professor, semestre e horário.
  #
  # @return [String]
  #
  def full_description
    "#{disciplina.nome} (#{disciplina.codigo}) - #{professor.nome} - #{semestre} - #{horario}"
  end

  ##
  # Retorna uma descrição simplificada da turma, contendo código da disciplina,
  # nome do professor e semestre.
  #
  # @return [String]
  #
  def simple_description
    "#{disciplina.codigo} - #{professor.nome} - #{semestre}"
  end
end
