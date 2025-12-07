class Template < ApplicationRecord
  belongs_to :administrador
  has_many :perguntas, -> { where(formulario_id: nil) }, dependent: :destroy
  has_many :formularios, dependent: :destroy
    
  validates :nome, presence: true, length: { minimum: 3, maximum: 100 }
  validates :administrador_id, presence: true
  
  # Allow nested creation of questions
  accepts_nested_attributes_for :perguntas, 
    allow_destroy: true,
    reject_if: ->(attrs) { attrs['texto'].blank? }
end