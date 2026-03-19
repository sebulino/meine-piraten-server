class CreateMessages < ActiveRecord::Migration[8.1]
  def change
    create_table :messages do |t|
      t.references :sender,    null: false, foreign_key: { to_table: :users }
      t.references :recipient, null: false, foreign_key: { to_table: :users }
      t.text       :body,      null: false
      t.boolean    :read,      null: false, default: false
      t.timestamps
    end

    add_index :messages, [:recipient_id, :read]
  end
end
