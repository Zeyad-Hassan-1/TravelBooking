class PaymentsController < ApplicationController
  def create_checkout_session
    Stripe.api_key = ENV["STRIPE_SECRET_KEY"]
    booking = Booking.find(params[:booking_id])  # بدل ما نعمل جديد، نجيب الموجود
    flight = booking.flight

    session = Stripe::Checkout::Session.create(
      payment_method_types: [ "card" ],
      line_items: [ {
        price_data: {
          currency: "usd",
          product_data: {
            name: "رحلة إلى #{flight.destination}"
          },
          unit_amount: (flight.price * 100).to_i
        },
        quantity: 1
      } ],
      mode: "payment",
      success_url: success_url(booking_id: booking.id),
      cancel_url: root_url + "?canceled=true",
    )

    booking.update(checkout_session_id: session.id)

    redirect_to session.url, allow_other_host: true
  end
  def success
    booking = Booking.find(params[:booking_id])
    booking.update(status: "complete") if booking.status == "pending"
    redirect_to root_path, notice: "تم الحجز بنجاح!"
  end
end
