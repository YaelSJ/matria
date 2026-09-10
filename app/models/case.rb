class Case < ApplicationRecord
  belongs_to :user
  belongs_to :representative, class_name: "User", optional: true

  has_many :case_files, dependent: :destroy

  validates :user_id, uniqueness: true

  # Estados del caso
  enum :status, {
    draft: "draft",
    in_review: "in_review",
    changes_requested: "changes_requested",
    approved: "approved",
    closed: "closed"
  }, default: :draft

  # Validaciones
  validates :status, presence: true
  validates :consent, acceptance: { accept: true, message: "debe ser otorgado para registrar el caso" }
  validates :risk_level,
            inclusion: { in: %w[low medium high critical] }

  def ready_for_submission?
    consent? && content.present? && opening_testimony&.transcript.present?
  end

  def submit_for_review!
    unless ready_for_submission?
      raise ActiveRecord::RecordInvalid.new(self),
            "El testimonio inicial requiere una transcripción"
    end

    update!(status: :in_review)
  end

  def editable_by_user?
    draft? || changes_requested?
  end

  def opening_testimony
    case_files.opening_testimony.first || case_files.where.not(transcript: [nil, ""]).order(:created_at, :id).first
  end
end
