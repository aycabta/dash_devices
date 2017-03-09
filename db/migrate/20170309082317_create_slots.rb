class CreateSlots < ActiveRecord::Migration[5.0]
  def change
    create_table :slots do |t|
      t.integer :device_id
      t.string :drs_slot_id
      t.string :name

      t.timestamps
    end
  end
end
