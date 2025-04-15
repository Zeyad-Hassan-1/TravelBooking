class WebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token

  def stripe
    payload = request.body.read
    sig_header = request.env["HTTP_STRIPE_SIGNATURE"]
    endpoint_secret = ENV["STRIPE_WEBHOOK_SECRET"]

    begin
      event = Stripe::Webhook.construct_event(payload, sig_header, endpoint_secret)

      case event.type
      when "checkout.session.completed"
        session = event.data.object
        booking = Booking.find_by(checkout_session_id: session.id)

        # Fallback to metadata if direct lookup fails
        booking ||= Booking.find_by(id: session.metadata.booking_id) if session.metadata.booking_id

        if booking
          booking.update(status: "paid")
          # Add any additional post-payment logic here
        else
          Rails.logger.error "Booking not found for session: #{session.id}"
        end

      when "checkout.session.async_payment_succeeded"
        # Handle async payments if needed
      end

      render json: { message: "success" }
    rescue JSON::ParserError => e
      render json: { error: "Invalid payload" }, status: 400
    rescue Stripe::SignatureVerificationError => e
      render json: { error: "Invalid signature" }, status: 400
    rescue => e
      Rails.logger.error "Stripe webhook error: #{e.message}"
      render json: { error: e.message }, status: 400
    end
  end
end
