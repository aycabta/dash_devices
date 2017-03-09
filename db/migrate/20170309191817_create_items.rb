class CreateItems < ActiveRecord::Migration[5.0]
  def change
    create_table :items do |t|
      t.integer :slot_id
      t.string :asin

      t.timestamps
    end
  end
end