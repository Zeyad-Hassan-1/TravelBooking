class CreateBookings < ActiveRecord::Migration[8.0]
  def change
    create_table :bookings do |t|
      t.references :flight, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :passenger_name
      t.string :passenger_email
      t.string :passenger_phone
      t.string :passenger_address
      t.timestamps
    end
  end
end
