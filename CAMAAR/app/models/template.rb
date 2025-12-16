##
# Representa um template de formulário criado por um administrador.
#
# Um Template define a estrutura base de um formulário, contendo
# um conjunto de {Pergunta}s reutilizáveis. A partir de um template,
# podem ser criados vários {Formulario}s associados a diferentes turmas.
#
# As perguntas do template são copiadas automaticamente para o formulário
# no momento de sua criação.
#
class Template < ApplicationRecord

  ##
  # Administrador responsável pela criação do template.
  #
  # @return [Administrador]
  #
  belongs_to :administrador

  ##
  # Perguntas associadas ao template.
  #
  # Apenas perguntas que ainda não foram copiadas para um formulário
  # (ou seja, com +formulario_id+ nulo).
  #
  # @return [ActiveRecord::Relation<Pergunta>]
  #
  has_many :perguntas,
           -> { where(formulario_id: nil) },
           dependent: :destroy

  ##
  # Formulários gerados a partir deste template.
  #
  # @return [ActiveRecord::Relation<Formulario>]
  #
  has_many :formularios, dependent: :destroy

  ##
  # Nome do template.
  #
  # @return [String]
  #
  validates :nome,
            presence: true,
            length: { minimum: 3, maximum: 100 }

  ##
  # Garante que todo template possua um administrador associado.
  #
  validates :administrador_id, presence: true

  ##
  # Permite a criação, edição e remoção de perguntas diretamente
  # a partir do formulário de template.
  #
  # @note
  #   - +allow_destroy+: permite remover perguntas existentes
  #   - +reject_if+: ignora perguntas vazias e ainda não persistidas
  #
  accepts_nested_attributes_for :perguntas,
                                allow_destroy: true,
                                reject_if: ->(attrs) {
                                  attrs['texto'].blank? && attrs['id'].blank?
                                }
end
