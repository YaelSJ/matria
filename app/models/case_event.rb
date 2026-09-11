class CaseEvent < ApplicationRecord
  belongs_to :case
  belongs_to :user

  validates :event_type, :to_status, presence: true
  validates :comment, presence: true, if: :comment_required?

  EVENT_TYPES = %w[submitted assigned review_started changes_requested resubmitted approved closed].freeze

  private

  def comment_required?
    event_type.in?(%w[changes_requested closed])
  end
end
