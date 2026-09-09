class Case < ApplicationRecord
  belongs_to :user
  belongs_to :representative, class_name: "User", optional: true

  has_many :case_files, dependent: :destroy

  validates :user_id, uniqueness: true

  # Estados del caso
  enum :status, {
    pending: "pending",
    in_review: "in_review",
    closed: "closed"
  }, default: :pending

  # Validaciones
  validates :status, presence: true
  validates :consent, acceptance: { accept: true, message: "debe ser otorgado para registrar el caso" }
end
