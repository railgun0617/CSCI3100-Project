class User < ApplicationRecord
  # Include default devise modules.
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :bookings, dependent: :destroy         
  # New: role enum (student is default)
  enum :role, { student: 'student', staff: 'staff' }, default: 'student'

  # Optional: helper methods
  def student?
    role == "student"
  end

  def staff?
    role == "staff"
  end
end