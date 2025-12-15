class Administrador < ApplicationRecord
  has_secure_password
  
  validates :nome, presence: true
  validates :email, presence: true, uniqueness: true
  validates :usuario, presence: true, uniqueness: true
  validates :departamento, presence: true
  
  has_many :templates, dependent: :destroy
  has_many :formularios, dependent: :destroy
end