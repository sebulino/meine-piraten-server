class CreateTelegramCursors < ActiveRecord::Migration[8.1]
  def change
    create_table :telegram_cursors do |t|
      t.string :name, null: false
      t.integer :last_update_id, limit: 8, default: 0, null: false
      t.timestamps
    end

    add_index :telegram_cursors, :name, unique: true
  end
end
