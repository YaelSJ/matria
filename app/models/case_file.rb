class CaseFile < ApplicationRecord
  belongs_to :case
  has_one_attached :audio

  enum :file_type, {
    opening_testimony: "opening_testimony",
    additional_audio: "additional_audio",
    ai_chat: "ai_chat",
    image: "image",
    document: "document"
  }, default: :document

  validates :title, :state, presence: true
end
