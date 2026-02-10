class Comment < ApplicationRecord
  belongs_to :task

  validates :text, presence: true
end
