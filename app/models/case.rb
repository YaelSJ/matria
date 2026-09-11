class Case < ApplicationRecord
  belongs_to :user
  belongs_to :representative, class_name: "User", optional: true

  has_many :case_files, dependent: :destroy
  has_many :case_events, dependent: :destroy

  validates :user_id, uniqueness: true

  # Estados del caso
  enum :status, {
    draft: "draft",
    pending_review: "pending_review",
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

  def submit_for_review!(actor: user)
    unless ready_for_submission?
      raise ActiveRecord::RecordInvalid.new(self),
            "El testimonio inicial requiere una transcripción"
    end

    previous_status = status
    update!(status: :pending_review)
    case_events.create!(user: actor, event_type: previous_status == "changes_requested" ? "resubmitted" : "submitted",
                        from_status: previous_status, to_status: status)
    CaseSummaryGenerator.new(self).call
  end

  def assign_to!(representative)
    raise ActiveRecord::RecordInvalid.new(self), "El caso no está pendiente de revisión" unless pending_review?

    transaction do
      update!(representative: representative, status: :in_review)
      case_events.create!(user: representative, event_type: "assigned",
                          from_status: "pending_review", to_status: "in_review")
    end
  end

  def start_review!(representative)
    unless representative_id == representative.id
      raise ActiveRecord::RecordInvalid.new(self),
            "El caso no está asignado a esta representante"
    end
    raise ActiveRecord::RecordInvalid.new(self), "El caso no está pendiente de revisión" unless pending_review?

    transaction do
      update!(status: :in_review)
      case_events.create!(user: representative, event_type: "review_started",
                          from_status: "pending_review", to_status: "in_review")
    end
  end

  def decide!(representative, next_status, comment: nil)
    raise ActiveRecord::RecordNotFound unless representative.admin? || representative_id == representative.id

    event_type = next_status.to_s
    if event_type.in?(%w[changes_requested closed]) && comment.blank?
      errors.add(:base, "El comentario es obligatorio")
      raise ActiveRecord::RecordInvalid.new(self)
    end

    transaction do
      previous_status = status
      update!(status: next_status)
      case_events.create!(user: representative, event_type: event_type,
                          from_status: previous_status, to_status: status, comment: comment)
    end
  end

  def editable_by_user?
    draft? || changes_requested?
  end

  def opening_testimony
    case_files.opening_testimony.first || case_files.where.not(transcript: [nil, ""]).order(:created_at, :id).first
  end
end
