class CaseFile < ApplicationRecord
  belongs_to :case
  has_one_attached :audio
  validates :title, :state, presence: true
end
