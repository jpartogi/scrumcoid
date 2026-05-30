class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  enum :role, { student: 0, admin: 1 }

  has_many :enrollments, dependent: :destroy
  has_many :class_schedules, through: :enrollments

  validates :name, presence: true

  after_update_commit :claim_paid_enrollments, if: :saved_change_to_encrypted_password?

  private

  def claim_paid_enrollments
    Enrollment.where(user_id: nil, visitor_email: email).find_each do |enrollment|
      next if enrollments.exists?(class_schedule_id: enrollment.class_schedule_id)

      enrollment.update!(user: self)
    end
  end
end
