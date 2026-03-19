class RenameEntityIdToParentEntityId < ActiveRecord::Migration[8.1]
  def change
    rename_column :entities, :entity_id, :parent_entity_id
  end
end
