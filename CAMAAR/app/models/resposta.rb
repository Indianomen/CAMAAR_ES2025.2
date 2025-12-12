class Resposta < ApplicationRecord
  belongs_to :aluno
  belongs_to :pergunta
  
  validates :texto, presence: true
  validates :aluno_id, uniqueness: { scope: :pergunta_id }
  
  # Through association to formulario
  delegate :formulario, to: :pergunta
  
  # For anonymous reporting
  def anonymous_data
    {
      resposta: texto,
      pergunta_id: pergunta_id,
      created_at: created_at
    }
  end
end