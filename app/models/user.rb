class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  after_create :create_case_for_user #se tiene que cambiar despues

  has_many :chats, dependent: :destroy
  has_one :case, dependent: :destroy
  has_many :representative_cases, class_name: "Case", foreign_key: :representative_id, dependent: :nullify

  # Roles de usuaria/representante/admin
  enum :role, { user: "user", representative: "representative", admin: "admin" }, default: :user

  # Validaciones
  validates :role, presence: true

  # Método para calcular la edad exacta a partir de birth_date
  def age
    return nil unless birth_date

    today = Date.current
    today.year - birth_date.year - (today.strftime("%m%d") < birth_date.strftime("%m%d") ? 1 : 0)
  end
#se tiene que cambiar despues
  def create_case_for_user
    Case.create!(user: self, consent: true, status: "draft", risk_level: "low")
  end
end
