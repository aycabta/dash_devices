class CreateDevices < ActiveRecord::Migration[5.0]
  def change
    create_table :devices do |t|
      t.integer :user_id
      t.string :model, null: false
      t.string :name, null: false
      t.boolean :scraped, default: false, null: false
      t.index :model, :unique => true

      t.timestamps
    end
  end
end
