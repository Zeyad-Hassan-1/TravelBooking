class AddCheckoutSessionIdToBookings < ActiveRecord::Migration[8.0]
  def change
    add_column :bookings, :checkout_session_id, :string
  end
end
