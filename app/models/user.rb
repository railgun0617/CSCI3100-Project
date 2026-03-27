class User < ApplicationRecord
  # Include default devise modules.
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # New: role enum (student is default)
  enum :role, { student: 0, staff: 1 }, default: :student

  # Optional: helper methods
  def student?
    role == "student"
  end

  def staff?
    role == "staff"
  end
end