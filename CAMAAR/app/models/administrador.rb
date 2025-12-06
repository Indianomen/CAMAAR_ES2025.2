class Administrador < ApplicationRecord
  has_secure_password
  
  # Validations
  validates :nome, presence: true
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :usuario, presence: true, uniqueness: true
  validates :departamento, presence: true
  
  # Relationships
  has_many :templates, dependent: :destroy
  has_many :formularios, dependent: :destroy
end