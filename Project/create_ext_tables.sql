create schema bookings;

-- drop external table bookings.pxf_aircrafts_data;
create external table bookings.pxf_aircrafts_data(
	aircraft_code bpchar(3), -- Aircraft code, IATA
	model         jsonb,     -- Aircraft model
	"range"       int4       -- Maximal flying distance, km
	)
  location ('pxf://bookings.aircrafts_data?PROFILE=JDBC&JDBC_DRIVER=org.postgresql.Driver&DB_URL=jdbc:postgresql://192.168.2.2:5432/demo&USER=postgres&PASS=postgres')   
  format 'CUSTOM' (FORMATTER='pxfwritable_import');

-- select * from bookings.pxf_aircrafts_data;

-- drop external table bookings.pxf_airports_data;
create external table bookings.pxf_airports_data(
	airport_code bpchar(3), -- Airport code
	airport_name jsonb,     -- Airport name
	city         jsonb,     -- City
	coordinates  text,      -- Airport coordinates (longitude and latitude)
	timezone     text       -- Airport time zone
	)
  location ('pxf://bookings.airports_data?PROFILE=JDBC&JDBC_DRIVER=org.postgresql.Driver&DB_URL=jdbc:postgresql://192.168.2.2:5432/demo&USER=postgres&PASS=postgres')   
  format 'CUSTOM' (FORMATTER='pxfwritable_import');	

-- select * from bookings.pxf_airports_data;

-- drop external table bookings.pxf_bookings;
create external table bookings.pxf_bookings(
	book_ref     bpchar(6),     -- Booking number
	book_date    text,          -- Booking date
	total_amount numeric(10, 2) -- Total booking cost
	)
  location ('pxf://bookings.bookings?PROFILE=JDBC&JDBC_DRIVER=org.postgresql.Driver&DB_URL=jdbc:postgresql://192.168.2.2:5432/demo&USER=postgres&PASS=postgres')   
  format 'CUSTOM' (FORMATTER='pxfwritable_import');	

-- select * from bookings.pxf_bookings;

-- drop external table bookings.pxf_flights;
create external table bookings.pxf_flights(
	flight_id           int4,        -- Flight ID
	flight_no           bpchar(6),   -- Flight number
	scheduled_departure text,        -- Scheduled departure time
	scheduled_arrival   text,        -- Scheduled arrival time
	departure_airport   bpchar(3),   -- Airport of departure
	arrival_airport     bpchar(3),   -- Airport of arrival
	status              varchar(20), -- Flight status
	aircraft_code       bpchar(3),   -- Aircraft code, IATA
	actual_departure    text,        -- Actual departure time
	actual_arrival      text         -- Actual arrival time
	)
  location ('pxf://bookings.flights?PROFILE=JDBC&JDBC_DRIVER=org.postgresql.Driver&DB_URL=jdbc:postgresql://192.168.2.2:5432/demo&USER=postgres&PASS=postgres')   
  format 'CUSTOM' (FORMATTER='pxfwritable_import');	

-- select * from bookings.pxf_flights;

-- drop external table bookings.pxf_seats;
create external table bookings.pxf_seats(
	aircraft_code   bpchar(3),   -- Aircraft code, IATA
	seat_no         varchar(4),  -- Seat number
	fare_conditions varchar(10)  -- Travel class
	)
  location ('pxf://bookings.seats?PROFILE=JDBC&JDBC_DRIVER=org.postgresql.Driver&DB_URL=jdbc:postgresql://192.168.2.2:5432/demo&USER=postgres&PASS=postgres')   
  format 'CUSTOM' (FORMATTER='pxfwritable_import');	

-- select * from bookings.pxf_seats;

-- drop external table bookings.pxf_tickets;
create external table bookings.pxf_tickets(
	ticket_no      bpchar(13),  -- Ticket number
	book_ref       bpchar(6),   -- Booking number
	passenger_id   varchar(20), -- Passenger ID
	passenger_name text,        -- Passenger name
	contact_data   jsonb        -- Passenger contact information
	)
  location ('pxf://bookings.tickets?PROFILE=JDBC&JDBC_DRIVER=org.postgresql.Driver&DB_URL=jdbc:postgresql://192.168.2.2:5432/demo&USER=postgres&PASS=postgres')   
  format 'CUSTOM' (FORMATTER='pxfwritable_import');	

-- select * from bookings.pxf_tickets;

-- drop external table bookings.pxf_ticket_flights;
create external table bookings.pxf_ticket_flights(
	ticket_no       bpchar(13),    -- Ticket number
	flight_id       int4,          -- Flight ID
	fare_conditions varchar(10),   -- Travel class
	amount          numeric(10, 2) -- Travel cost
	)
  location ('pxf://bookings.ticket_flights?PROFILE=JDBC&JDBC_DRIVER=org.postgresql.Driver&DB_URL=jdbc:postgresql://192.168.2.2:5432/demo&USER=postgres&PASS=postgres')   
  format 'CUSTOM' (FORMATTER='pxfwritable_import');	

-- select * from bookings.pxf_ticket_flights;

-- drop external table bookings.pxf_boarding_passes;
create external table bookings.pxf_boarding_passes(
	ticket_no   bpchar(13), -- Ticket number
	flight_id   int4,       -- Flight ID
	boarding_no int4,       -- Boarding pass number
	seat_no     varchar(4)  -- Seat number
	)
  location ('pxf://bookings.boarding_passes?PROFILE=JDBC&JDBC_DRIVER=org.postgresql.Driver&DB_URL=jdbc:postgresql://192.168.2.2:5432/demo&USER=postgres&PASS=postgres')   
  format 'CUSTOM' (FORMATTER='pxfwritable_import');	

-- select * from bookings.pxf_boarding_passes;
