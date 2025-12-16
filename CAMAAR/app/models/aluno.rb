##
# Representa um usuário do tipo Aluno no sistema.
#
# O Aluno pode estar matriculado em turmas, responder formulários
# e autenticar-se no sistema por meio de senha.
#
# Utiliza autenticação segura via +has_secure_password+.
#
class Aluno < ApplicationRecord

  ##
  # Habilita autenticação baseada em senha utilizando BCrypt.
  #
  # Requisitos:
  # - A tabela deve possuir a coluna +password_digest+.
  #
  # Efeitos colaterais:
  # - Adiciona métodos como +authenticate+, +password+ e +password=+.
  #
  has_secure_password

  ##
  # Valida o comprimento mínimo da senha.
  #
  # A validação só é executada se a senha estiver presente
  # (útil em atualizações parciais).
  #
  # @return [void]
  #
  validates :password, length: { minimum: 6 }, if: -> { password.present? }

  ##
  # Valida a presença do nome do aluno.
  #
  # @return [void]
  #
  validates :nome, presence: true

  ##
  # Valida a presença, unicidade e formato do email.
  #
  # @return [void]
  #
  validates :email,
            presence: true,
            uniqueness: true,
            format: { with: URI::MailTo::EMAIL_REGEXP }

  ##
  # Valida a presença e unicidade da matrícula do aluno.
  #
  # @return [void]
  #
  validates :matricula, presence: true, uniqueness: true

  ##
  # Valida a presença e unicidade do nome de usuário (login).
  #
  # @return [void]
  #
  validates :usuario, presence: true, uniqueness: true

  ##
  # Valida a presença do curso do aluno.
  #
  # @return [void]
  #
  validates :curso, presence: true

  ##
  # Valida a presença do departamento do aluno.
  #
  # @return [void]
  #
  validates :departamento, presence: true

  ##
  # Associação N:N entre alunos e turmas.
  #
  # @return [ActiveRecord::Associations::CollectionProxy<Turma>]
  #
  has_and_belongs_to_many :turmas, join_table: :alunos_turmas

  ##
  # Associação N:N entre alunos e formulários atribuídos para resposta.
  #
  # @return [ActiveRecord::Associations::CollectionProxy<Formulario>]
  #
  has_and_belongs_to_many :formularios_respostas,
                          class_name: 'Formulario',
                          join_table: :alunos_formularios

  ##
  # Associação com respostas enviadas pelo aluno.
  #
  # @return [ActiveRecord::Associations::CollectionProxy<Resposta>]
  #
  # Efeitos colaterais:
  # - Ao remover o aluno, todas as respostas associadas
  #   são removidas automaticamente.
  #
  has_many :respostas, dependent: :destroy

  ##
  # Retorna todos os formulários associados às turmas
  # nas quais o aluno está matriculado.
  #
  # @return [ActiveRecord::Relation<Formulario>]
  #
  # Não recebe argumentos.
  #
  # Não possui efeitos colaterais.
  #
  def formularios
    Formulario.joins(turma: :alunos).where(alunos: { id: id })
  end

  ##
  # Retorna os formulários que o aluno ainda não respondeu.
  #
  # O método identifica formulários que já possuem respostas
  # do aluno e os exclui da lista final.
  #
  # @return [ActiveRecord::Relation<Formulario>]
  #
  # Não recebe argumentos.
  #
  # Não possui efeitos colaterais.
  #
  def formularios_pendentes
    formularios_com_resposta = Formulario
                              .joins(perguntas: :respostas)
                              .where(respostas: { aluno_id: id })
                              .distinct
                              .pluck(:id)

    formularios.where.not(id: formularios_com_resposta)
  end
end
