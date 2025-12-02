class Student < ApplicationRecord

  has_secure_password
  
  validates :email, presence: true, uniqueness: true
  validates :matricula, presence: true, uniqueness: true
  validates :usuario, presence: true, uniqueness: true

end
