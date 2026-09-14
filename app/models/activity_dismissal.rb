class ActivityDismissal < ApplicationRecord
  belongs_to :user
  belongs_to :case_event

  validates :case_event_id, uniqueness: { scope: :user_id }
end
