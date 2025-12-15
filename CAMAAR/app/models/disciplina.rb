class Disciplina < ApplicationRecord
  validates :codigo, presence: true, uniqueness: true
  validates :nome, presence: true
  
  has_many :turmas, dependent: :destroy
end