class Professor < ApplicationRecord
  has_secure_password
  
  validates :password, length: { minimum: 6 }, if: -> { password.present? }
  validates :nome, presence: true
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :usuario, presence: true, uniqueness: true
  validates :departamento, presence: true
  validates :formacao, presence: true
  
  has_many :turmas, dependent: :destroy
  has_many :disciplinas, through: :turmas
end