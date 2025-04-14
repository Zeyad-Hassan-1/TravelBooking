# Clear existing data
Flight.destroy_all
Airport.destroy_all

# Create airports
airport1 = Airport.create!(location: "New York")
airport2 = Airport.create!(location: "Los Angeles")
airport3 = Airport.create!(location: "Chicago")
airport4 = Airport.create!(location: "Miami")

puts "Airports created: #{Airport.count}"

# Create flights
Flight.create!(
  destination: "Los Angeles",
  arrival_airport_id: airport2.id,
  departure_airport_id: airport1.id,
  departure_date: DateTime.now + 1.day,
  price: 300
)

Flight.create!(
  destination: "New York",
  arrival_airport_id: airport1.id,
  departure_airport_id: airport2.id,
  departure_date: DateTime.now + 2.days,
  price: 350
)

Flight.create!(
  destination: "Chicago",
  arrival_airport_id: airport3.id,
  departure_airport_id: airport4.id,
  departure_date: DateTime.now + 3.days,
  price: 200
)

Flight.create!(
  destination: "Miami",
  arrival_airport_id: airport4.id,
  departure_airport_id: airport3.id,
  departure_date: DateTime.now + 4.days,
  price: 250
)

puts "Flights created: #{Flight.count}"