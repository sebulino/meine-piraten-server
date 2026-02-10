class CreateComments < ActiveRecord::Migration[8.0]
  def change
    create_table :comments do |t|
      t.references :task, null: false, foreign_key: true
      t.string :author_name
      t.text :text

      t.timestamps
    end
  end
end
