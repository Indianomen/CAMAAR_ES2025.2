##
# Representa uma pergunta pertencente a um template ou a um formulário.
#
# Uma pergunta pode estar associada a:
# - um Template (quando faz parte de um modelo reutilizável), ou
# - um Formulario (quando já foi instanciada para uma turma específica).
#
# Uma pergunta nunca pertence simultaneamente aos dois; o método {#owner}
# identifica dinamicamente o seu "dono".
#
class Pergunta < ApplicationRecord

  ##
  # Template ao qual a pergunta pertence, quando for uma pergunta-base.
  #
  # @return [Template, nil]
  #
  # A associação é opcional pois a pergunta pode pertencer
  # diretamente a um formulário.
  #
  belongs_to :template, optional: true

  ##
  # Formulário ao qual a pergunta pertence, quando já foi aplicada.
  #
  # @return [Formulario, nil]
  #
  # A associação é opcional pois a pergunta pode existir apenas
  # como parte de um template.
  #
  belongs_to :formulario, optional: true

  ##
  # Respostas associadas a esta pergunta.
  #
  # @return [ActiveRecord::Associations::CollectionProxy<Resposta>]
  #
  # Efeitos colaterais:
  # - Ao remover a pergunta, todas as respostas associadas
  #   são removidas automaticamente.
  #
  has_many :respostas, dependent: :destroy

  ##
  # Texto da pergunta.
  #
  # @return [String]
  #
  validates :texto, presence: true

  ##
  # Retorna o objeto "dono" da pergunta.
  #
  # Caso a pergunta pertença a um template, ele será retornado.
  # Caso contrário, retorna o formulário associado.
  #
  # @return [Template, Formulario, nil]
  #
  def owner
    template || formulario
  end
end
