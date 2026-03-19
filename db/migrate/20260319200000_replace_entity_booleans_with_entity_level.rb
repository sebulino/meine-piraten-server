class ReplaceEntityBooleansWithEntityLevel < ActiveRecord::Migration[8.1]
  def up
    add_column :entities, :entity_level, :string

    execute <<-SQL
      UPDATE entities SET entity_level = CASE
        WHEN "LV" = 1 THEN 'LV'
        WHEN "KV" = 1 THEN 'KV'
        WHEN "OV" = 1 THEN 'OV'
        ELSE NULL
      END
    SQL

    remove_column :entities, :LV, :boolean
    remove_column :entities, :KV, :boolean
    remove_column :entities, :OV, :boolean
  end

  def down
    add_column :entities, :LV, :boolean
    add_column :entities, :KV, :boolean
    add_column :entities, :OV, :boolean

    execute <<-SQL
      UPDATE entities SET
        "LV" = CASE WHEN entity_level = 'LV' THEN 1 ELSE 0 END,
        "KV" = CASE WHEN entity_level = 'KV' THEN 1 ELSE 0 END,
        "OV" = CASE WHEN entity_level = 'OV' THEN 1 ELSE 0 END
    SQL

    remove_column :entities, :entity_level, :string
  end
end
