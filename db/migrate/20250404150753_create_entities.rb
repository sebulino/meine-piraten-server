class CreateEntities < ActiveRecord::Migration[8.0]
  def change
    create_table :entities do |t|
      t.string :name
      t.boolean :LV
      t.boolean :OV
      t.boolean :KV
      t.integer :entity_id

      t.timestamps
    end
  end
end
