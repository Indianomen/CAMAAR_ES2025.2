##
# Representa uma disciplina acadêmica no sistema.
#
# Uma disciplina possui um código único, um nome e pode
# estar associada a várias turmas.
#
class Disciplina < ApplicationRecord

  ##
  # Valida a presença e unicidade do código da disciplina.
  #
  # @return [void]
  #
  validates :codigo, presence: true, uniqueness: true

  ##
  # Valida a presença do nome da disciplina.
  #
  # @return [void]
  #
  validates :nome, presence: true

  ##
  # Associação entre disciplina e turmas.
  #
  # @return [ActiveRecord::Associations::CollectionProxy<Turma>]
  #
  # Efeitos colaterais:
  # - Ao remover a disciplina, todas as turmas associadas
  #   são removidas automaticamente.
  #
  has_many :turmas, dependent: :destroy
end
