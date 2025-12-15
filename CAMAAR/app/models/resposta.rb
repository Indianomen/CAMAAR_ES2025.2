class Resposta < ApplicationRecord
  belongs_to :aluno
  belongs_to :pergunta

  self.table_name = 'respostas' if self.table_name != 'respostas'

  validates :texto, presence: true
  validates :aluno_id, uniqueness: { scope: :pergunta_id }
  
  delegate :formulario, to: :pergunta
  
  def anonymous_data
    {
      resposta: texto,
      pergunta_id: pergunta_id,
      created_at: created_at
    }
  end
end