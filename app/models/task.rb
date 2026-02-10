class Task < ApplicationRecord
  belongs_to :category
  belongs_to :entity
  has_many :comments, dependent: :destroy

  validates :status, inclusion: { in: %w[open claimed done] }
end
