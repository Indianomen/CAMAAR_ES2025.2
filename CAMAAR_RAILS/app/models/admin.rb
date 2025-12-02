class Admin < ApplicationRecord
  
  has_secure_password

  validates :email, presence: true, uniqueness: true
  validates :usuario, presence: true, uniqueness: true
  
  has_many :templates, dependent: :destroy
  has_many :formularios, dependent: :destroy
end
