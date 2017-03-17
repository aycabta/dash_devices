class CreateUsers < ActiveRecord::Migration[5.0]
  def change
    create_table :users do |t|
      t.string :uid, null: false
      t.string :provider, null: false
      t.string :token
      t.string :refresh_token
      t.string :name
      t.string :email

      t.timestamps
    end
  end
end
