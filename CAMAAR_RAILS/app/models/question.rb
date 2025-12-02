class Question < ApplicationRecord
  
  belongs_to :template
  belongs_to :formulario, optional: true
  
  validates :texto, presence: true
end
