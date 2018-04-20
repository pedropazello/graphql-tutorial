class User < ApplicationRecord
  has_secure_password

  validates :name, presence: true
  validates :email, precence: true, uniqueness: true
end
