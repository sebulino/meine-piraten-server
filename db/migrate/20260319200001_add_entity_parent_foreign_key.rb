class AddEntityParentForeignKey < ActiveRecord::Migration[8.1]
  def change
    add_index :entities, :entity_id
    add_foreign_key :entities, :entities, column: :entity_id
  end
end
