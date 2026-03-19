json.extract! entity, :id, :name, :entity_level, :entity_id, :created_at, :updated_at
json.parent_entity_name entity.parent_entity&.name
json.url entity_url(entity, format: :json)
