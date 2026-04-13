class Tenant < ApplicationRecord
  has_many :users
  has_many :venues
  has_many :equipment

  validates :name, presence: true, uniqueness: true

  def self.ransackable_attributes(auth_object = nil)
    %w[name slug]
  end
end