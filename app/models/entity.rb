class Entity < ApplicationRecord
  has_many :tasks

  ENTITY_LEVELS = %w[LV KV OV].freeze
  ENTITY_LEVEL_LABELS = {
    "LV" => "Landesverband",
    "KV" => "Kreisverband",
    "OV" => "Ortsverband"
  }.freeze

  validates :entity_level, inclusion: { in: ENTITY_LEVELS }, allow_nil: true

  def entity_level_label
    ENTITY_LEVEL_LABELS[entity_level]
  end
end
