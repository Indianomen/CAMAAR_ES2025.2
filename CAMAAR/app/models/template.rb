class Template < ApplicationRecord
  # Relationships
  belongs_to :administrador
  has_many :perguntas, dependent: :destroy
  has_many :formularios, dependent: :destroy
  
  # Validations
  validates :nome, presence: true
  validates :administrador_id, presence: true
  
  # Accept nested attributes for perguntas
  accepts_nested_attributes_for :perguntas, allow_destroy: true
end