class Entity < ApplicationRecord
  belongs_to :parent_entity, class_name: "Entity", optional: true, foreign_key: :entity_id
  has_many :sub_entities, class_name: "Entity", foreign_key: :entity_id, dependent: :nullify

  has_many :tasks

  ENTITY_LEVELS = %w[BV LV BZV KV].freeze
  ENTITY_LEVEL_LABELS = {
    "BV" => "Bundesverband",
    "LV" => "Landesverband",
    "BZV" => "Bezirksverband",
    "KV" => "Kreisverband"
  }.freeze

  validates :entity_level, inclusion: { in: ENTITY_LEVELS }, allow_nil: true
  validate :parent_is_not_self
  validate :parent_is_not_descendant

  def entity_level_label
    ENTITY_LEVEL_LABELS[entity_level]
  end

  private

  def parent_is_not_self
    errors.add(:entity_id, "kann nicht auf sich selbst verweisen") if entity_id.present? && entity_id == id
  end

  def parent_is_not_descendant
    return if entity_id.blank?
    ancestor = Entity.find_by(id: entity_id)
    visited = Set.new([ id ])
    while ancestor
      if visited.include?(ancestor.id)
        errors.add(:entity_id, "würde einen Zirkelbezug erzeugen")
        break
      end
      visited << ancestor.id
      ancestor = Entity.find_by(id: ancestor.entity_id)
    end
  end
end
