class BookingsController < ApplicationController
  def index
    @bookings = Booking.all
  end

  def show
    @booking = Booking.find(params[:id])
  end

  def new
    @booking = Booking.new
    @flight = Flight.find(params[:flight_id]) if params[:flight_id].present?
  end

  def create
    @booking = Booking.new(booking_params)
    @booking.user_id = current_user.id if user_signed_in?
    @booking.flight_id = params[:flight_id] || params[:booking][:flight_id] # Fallback
    @booking.passenger_email = current_user.email if user_signed_in?

    if @booking.save
      redirect_to @booking, notice: "Booking was successfully created."
    else
      puts "Errors: #{@booking.errors.full_messages}"
      render :new
    end
  end

  private
  def booking_params
    params.require(:booking).permit(:user_id, :flight_id, :passenger_name, :passenger_phone, :passenger_address, :Nkids, :Nadults, :travel_class,  :zip_code)
  end
end
