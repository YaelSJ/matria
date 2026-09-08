class Case < ApplicationRecord
  belongs_to :user
  belongs_to :representative, class_name: "User", optional: true

  validates :user_id, uniqueness: true
  has_many :case_files, dependent: :destroy

end
