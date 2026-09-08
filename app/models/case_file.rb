class CaseFile < ApplicationRecord
  belongs_to :case
  validates :title, :state, presence: true
end
