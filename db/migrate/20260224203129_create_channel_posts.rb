class CreateChannelPosts < ActiveRecord::Migration[8.1]
  def change
    create_table :channel_posts do |t|
      t.integer :chat_id, limit: 8, null: false
      t.integer :message_id, limit: 8, null: false
      t.datetime :posted_at, null: false
      t.text :text
      t.json :raw_json
      t.timestamps
    end

    add_index :channel_posts, :chat_id
    add_index :channel_posts, :message_id
    add_index :channel_posts, :posted_at
    add_index :channel_posts, [:chat_id, :message_id], unique: true
  end
end
