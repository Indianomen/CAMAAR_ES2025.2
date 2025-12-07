class Pergunta < ApplicationRecord
  # Relationships
  belongs_to :template
  belongs_to :formulario, optional: true
    
  # Validations
  validates :texto, presence: true
  
  # Scopes
  scope :do_template, ->(template_id) { where(template_id: template_id, formulario_id: nil) }
  scope :do_formulario, ->(formulario_id) { where(formulario_id: formulario_id) }
end