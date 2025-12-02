class Classess < ApplicationRecord

  belongs_to :professor
  belongs_to :disciplina
  belongs_to :formulario, optional: true
  
  validates :semestre, presence: true
  validates :horario, presence: true
  
  has_and_belongs_to_many :alunos, join_table: :alunos_turmas
end
