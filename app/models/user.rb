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

  attr_accessor :require_registration_location

  validates :role, presence: true
  validate :registration_location_is_valid, if: :require_registration_location

  after_create :create_case_for_user, if: :user?

  def age
    return nil unless birth_date

    today = Date.current
    today.year - birth_date.year -
      (today.strftime("%m%d") < birth_date.strftime("%m%d") ? 1 : 0)
  end

  private

  def registration_location_is_valid
    errors.add(:user_country, "selecciona México de la lista") unless user_country == MexicanLocations::COUNTRY

    errors.add(:state, "selecciona un estado de la lista") unless MexicanLocations.states.include?(state)

    return if MexicanLocations.municipalities(state).include?(city)

    errors.add(:city, "selecciona un municipio o alcaldía del estado elegido")
  end

  def create_case_for_user
    Case.create!(
      user: self,
      consent: true,
      status: :draft,
      risk_level: :low
    )
  end
end
