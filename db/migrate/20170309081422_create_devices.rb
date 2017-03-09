class CreateDevices < ActiveRecord::Migration[5.0]
  def change
    create_table :devices do |t|
      t.string :model
      t.string :name
      t.boolean :scraped, default: false, null: false

      t.timestamps
    end
  end
end
