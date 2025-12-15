class Pergunta < ApplicationRecord
  belongs_to :template, optional: true
  belongs_to :formulario, optional: true
  has_many :respostas, dependent: :destroy
  
  validates :texto, presence: true
  
  def owner
    template || formulario
  end
end