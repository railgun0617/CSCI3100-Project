class User < ApplicationRecord
  has_many :bookings, dependent: :destroy # User can have multiple bookings 
  has_many :venues, through: :bookings
  has_many :equipment, through: :bookings
  belongs_to :tenant, optional: true   # only for staff users
  validates :tenant_id, presence: true, if: -> { staff? }

  # Include default devise modules.
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
         
  # New: role enum (student is default)
  enum :role, { student: 'student', staff: 'staff', admin: 'admin' }, default: 'student'

  # Optional: helper methods
  def student?
    role == "student"
  end

  def staff?
    role == "staff"
  end
end