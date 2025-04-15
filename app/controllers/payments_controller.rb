class PaymentsController < ApplicationController
  def create_checkout_session
    # جلب بيانات الرحلة بناءً على الـ ID اللي جاي في الـ params
    flight = Flight.find(params[:flight_id])

    session = Stripe::Checkout::Session.create(
      payment_method_types: [ "card" ],
      line_items: [ {
        price_data: {
          currency: "usd",
          product_data: {
            name: "رحلة إلى #{flight.destination}" # اسم الرحلة الديناميكي
          },
          unit_amount: (flight.price * 100).to_i # السعر يتحول إلى سنتات
        },
        quantity: 1
      } ],
      mode: "payment",
      success_url: root_url + "?success=true&flight_id=#{flight.id}",
      cancel_url: root_url + "?canceled=true",
    )

    redirect_to session.url, allow_other_host: true
  end
end
