class RenameEntityIdAndAddForeignKey < ActiveRecord::Migration[8.1]
  def change
    rename_column :entities, :entity_id, :parent_entity_id
    add_index :entities, :parent_entity_id
    add_foreign_key :entities, :entities, column: :parent_entity_id
  end
end
