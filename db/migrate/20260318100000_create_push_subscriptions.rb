class CreatePushSubscriptions < ActiveRecord::Migration[8.1]
  def change
    create_table :push_subscriptions do |t|
      t.string  :token,            null: false
      t.string  :platform,         null: false, default: "ios"
      t.references :user,          null: false, foreign_key: true
      t.boolean :messages_enabled, null: false, default: false
      t.boolean :todos_enabled,    null: false, default: false
      t.boolean :forum_enabled,    null: false, default: false
      t.boolean :news_enabled,     null: false, default: false
      t.timestamps
    end

    add_index :push_subscriptions, :token, unique: true
  end
end
