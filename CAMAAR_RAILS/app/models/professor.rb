class Professor < ApplicationRecord
  
  has_secure_password

  validates :email, presence: true, uniqueness: true
  validates :usuario, presence: true, uniqueness: true
  
  has_many :turmas, dependent: :destroy
end
