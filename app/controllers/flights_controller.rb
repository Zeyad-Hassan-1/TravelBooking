class FlightsController < ApplicationController
  before_action :authenticate_user!
  def index
    @airports = Airport.all
    @flights = Flight.all
    @dates = Flight.select(:departure_date).distinct.map { |f| f.departure_date.to_date }.uniq.sort
    @prices = Flight.select(:price).distinct.map { |f| f.price }
    @destination = Flight.select(:destination).distinct.map { |f| f.destination }.uniq.sort
    if params[:commit]
      @flights = Flight.where(
        destination: params[:destination],
        departure_airport_id: params[:departure_airport_id],
        ).where("date(departure_date) = ?", params[:departure_date])
      @flights = @flights.where("price <= ?", params[:max_price]) if params[:max_price].present?
    else
      @flights = []
    end
  end

  def show
    @flight = Flight.find(params[:id])
  end

  private

  def flight_params
    params.require(:flight).permit(:departure_airport_id, :arrival_airport_id, :airline_id, :departure_date)
  end
end
