class CreateAdminRequestsAndAddSuperadmin < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :superadmin, :boolean, default: false, null: false

    create_table :admin_requests do |t|
      t.references :user, null: false, foreign_key: true
      t.text :reason
      t.string :status, default: "pending", null: false
      t.references :reviewed_by, foreign_key: { to_table: :users }
      t.datetime :reviewed_at
      t.timestamps
    end
  end
end
