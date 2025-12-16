##
# Representa uma resposta fornecida por um aluno a uma pergunta.
#
# A Resposta é a entidade que registra o conteúdo textual respondido
# por um {Aluno} para uma {Pergunta}. Cada aluno só pode responder
# uma mesma pergunta uma única vez.
#
class Resposta < ApplicationRecord

  ##
  # Aluno que forneceu a resposta.
  #
  # @return [Aluno]
  #
  belongs_to :aluno

  ##
  # Pergunta à qual a resposta pertence.
  #
  # @return [Pergunta]
  #
  belongs_to :pergunta

  ##
  # Garante explicitamente o nome da tabela no banco de dados.
  #
  # @note Útil em cenários de migração, herança ou conflitos de naming.
  #
  self.table_name = 'respostas' if self.table_name != 'respostas'

  ##
  # Texto da resposta fornecida pelo aluno.
  #
  # @return [String]
  #
  validates :texto, presence: true

  ##
  # Garante que um aluno só responda uma pergunta uma única vez.
  #
  # @note Implementa uma unicidade lógica (aluno_id + pergunta_id).
  #
  validates :aluno_id, uniqueness: { scope: :pergunta_id }

  ##
  # Delegação para acesso direto ao formulário associado à pergunta.
  #
  # @return [Formulario]
  #
  delegate :formulario, to: :pergunta

  ##
  # Retorna os dados da resposta sem identificação do aluno.
  #
  # Útil para relatórios, estatísticas ou visualização anônima
  # de respostas em formulários.
  #
  # @return [Hash]
  #   - :resposta [String] texto da resposta
  #   - :pergunta_id [Integer] identificador da pergunta
  #   - :created_at [ActiveSupport::TimeWithZone] data de criação
  #
  def anonymous_data
    {
      resposta: texto,
      pergunta_id: pergunta_id,
      created_at: created_at
    }
  end
end
