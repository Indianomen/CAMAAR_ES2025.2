class Disciplina < ApplicationRecord
  # Validations
  validates :codigo, presence: true, uniqueness: true
  validates :nome, presence: true
  
  # Relationships
  has_many :turmas, dependent: :destroy
end