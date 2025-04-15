class AddFieldsToBooking < ActiveRecord::Migration[8.0]
  def change
    add_column :bookings, :zip_code, :integer
    add_column :bookings, :Nkids, :integer
    add_column :bookings, :Nadults, :integer
    add_column :bookings, :travel_class, :string
  end
end
