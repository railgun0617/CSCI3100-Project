class Tenant < ApplicationRecord
  has_many :users
  has_many :venues
  has_many :equipment

  validates :name, presence: true, uniqueness: true
end