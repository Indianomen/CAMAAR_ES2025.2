class Template < ApplicationRecord
  
  belongs_to :administrador
  has_many :perguntas, dependent: :destroy
  has_many :formularios, dependent: :destroy
  
  validates :nome, presence: true
end