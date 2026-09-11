class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :chats, dependent: :destroy
  has_one :case, dependent: :destroy
  has_many :representative_cases,
           class_name: "Case",
           foreign_key: :representative_id,
           dependent: :nullify

  enum :role, {
    user: "user",
    representative: "representative",
    admin: "admin"
  }, default: :user

  validates :role, presence: true

  after_create :create_case_for_user, if: :user?

  def age
    return nil unless birth_date

    today = Date.current
    today.year - birth_date.year -
      (today.strftime("%m%d") < birth_date.strftime("%m%d") ? 1 : 0)
  end

  private

  def create_case_for_user
    Case.create!(
      user: self,
      consent: true,
      status: :draft,
      risk_level: :low
    )
  end
end
