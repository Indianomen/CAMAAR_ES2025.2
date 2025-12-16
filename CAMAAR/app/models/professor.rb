##
# Representa um professor do sistema.
#
# O Professor é responsável por ministrar disciplinas por meio de turmas.
# Ele possui autenticação própria e pode estar associado a várias disciplinas
# indiretamente, através das turmas que leciona.
#
class Professor < ApplicationRecord

  ##
  # Habilita autenticação por senha usando BCrypt.
  #
  # Campos esperados no banco:
  # - password_digest
  #
  has_secure_password

  ##
  # Validação da senha.
  #
  # @note A validação só é aplicada quando a senha está presente,
  #   permitindo atualizações em outros campos sem exigir redefinição.
  #
  validates :password, length: { minimum: 6 }, if: -> { password.present? }

  ##
  # Nome completo do professor.
  #
  # @return [String]
  #
  validates :nome, presence: true

  ##
  # Email institucional do professor.
  #
  # @return [String]
  #
  # Deve ser único e seguir o formato padrão de email.
  #
  validates :email,
            presence: true,
            uniqueness: true,
            format: { with: URI::MailTo::EMAIL_REGEXP }

  ##
  # Nome de usuário utilizado para login.
  #
  # @return [String]
  #
  validates :usuario, presence: true, uniqueness: true

  ##
  # Departamento ao qual o professor pertence.
  #
  # @return [String]
  #
  validates :departamento, presence: true

  ##
  # Formação acadêmica do professor.
  #
  # @return [String]
  #
  validates :formacao, presence: true

  ##
  # Turmas ministradas pelo professor.
  #
  # @return [ActiveRecord::Associations::CollectionProxy<Turma>]
  #
  # Efeito colateral:
  # - Ao remover o professor, todas as suas turmas são removidas.
  #
  has_many :turmas, dependent: :destroy

  ##
  # Disciplinas associadas ao professor através das turmas.
  #
  # @return [ActiveRecord::Associations::CollectionProxy<Disciplina>]
  #
  has_many :disciplinas, through: :turmas
end
