require 'faker'

# Clear existing data
Flight.destroy_all
Airport.destroy_all

# Create a smaller set of airports
airport_locations = [
  "New York", "Los Angeles", "Chicago", "Miami", "San Francisco",
  "Houston", "Atlanta"
]

airports = airport_locations.map do |location|
  Airport.create!(location: location)
end

puts "Airports created: #{Airport.count}"

# Create flights for the next 7 days with limited routes
start_date = Date.today
end_date = Date.today + 7.days

(start_date..end_date).each do |date|
  airports.each do |departure_airport|
    # Randomly select 3-5 arrival airports for each departure airport
    arrival_airports = airports.sample(rand(3..5))

    arrival_airports.each do |arrival_airport|
      next if departure_airport == arrival_airport # Skip flights to the same airport

      # Create a flight with a random departure time and price
      Flight.create!(
        destination: arrival_airport.location,
        arrival_airport_id: arrival_airport.id,
        departure_airport_id: departure_airport.id,
        departure_date: date.to_datetime + rand(0..23).hours + rand(0..59).minutes, # Random time during the day
        price: rand(100..500) # Lower price range for more realistic data
      )
    end
  end
end

puts "Flights created: #{Flight.count}"
