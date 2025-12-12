class Pergunta < ApplicationRecord
  belongs_to :template, optional: true
  belongs_to :formulario, optional: true
  has_many :respostas, dependent: :destroy
  
  validates :texto, presence: true
  
  # Returns the owner
  def owner
    template || formulario
  end
end