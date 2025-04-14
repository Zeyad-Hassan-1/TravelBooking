class CreateFlights < ActiveRecord::Migration[8.0]
  def change
    create_table :flights do |t|
      t.string :destination
      t.references :arrival_airport, null: false, foreign_key: { to_table: :airports }
      t.references :departure_airport, null: false, foreign_key: { to_table: :airports }
      t.datetime :departure_date
      t.integer :price

      t.timestamps
    end
  end
end
