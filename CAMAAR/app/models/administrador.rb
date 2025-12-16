##
# Representa um usuário do tipo Administrador no sistema.
#
# O Administrador é responsável por gerenciar templates, formulários
# e acessar funcionalidades administrativas da aplicação.
#
# Utiliza autenticação segura via +has_secure_password+.
#
class Administrador < ApplicationRecord

  ##
  # Habilita autenticação baseada em senha utilizando BCrypt.
  #
  # Requisitos:
  # - A tabela deve possuir a coluna +password_digest+.
  #
  # Efeitos colaterais:
  # - Adiciona métodos de autenticação como +authenticate+.
  #
  has_secure_password

  ##
  # Valida a presença do nome do administrador.
  #
  # @return [void]
  #
  validates :nome, presence: true

  ##
  # Valida a presença e unicidade do email do administrador.
  #
  # @return [void]
  #
  validates :email, presence: true, uniqueness: true

  ##
  # Valida a presença e unicidade do usuário (login) do administrador.
  #
  # @return [void]
  #
  validates :usuario, presence: true, uniqueness: true

  ##
  # Valida a presença do departamento ao qual o administrador pertence.
  #
  # @return [void]
  #
  validates :departamento, presence: true

  ##
  # Associação com templates criados pelo administrador.
  #
  # @return [ActiveRecord::Associations::CollectionProxy<Template>]
  #
  # Efeitos colaterais:
  # - Ao remover o administrador, todos os templates associados
  #   são removidos automaticamente.
  #
  has_many :templates, dependent: :destroy

  ##
  # Associação com formulários criados pelo administrador.
  #
  # @return [ActiveRecord::Associations::CollectionProxy<Formulario>]
  #
  # Efeitos colaterais:
  # - Ao remover o administrador, todos os formulários associados
  #   são removidos automaticamente.
  #
  has_many :formularios, dependent: :destroy
end
