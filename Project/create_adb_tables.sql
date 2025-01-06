-- drop table bookings.aircrafts_data;
create table bookings.aircrafts_data(                 -- 9 записей
	aircraft_code bpchar(3), -- Aircraft code, IATA
	model         jsonb,     -- Aircraft model
	"range"       int4       -- Maximal flying distance, km
	)
	with (appendoptimized = true)
    distributed replicated;

insert into bookings.aircrafts_data (select * from bookings.pxf_aircrafts_data); 

-- select * from bookings.aircrafts_data;
-- select count(*) from bookings.aircrafts_data;

-- drop table bookings.airports_data;
create table bookings.airports_data(                  -- 104 записи
	airport_code bpchar(3), -- Airport code
	airport_name jsonb,     -- Airport name
	city         jsonb,     -- City
	coordinates  text,      -- Airport coordinates (longitude and latitude)
	timezone     text       -- Airport time zone
	)
	with (appendoptimized = true)
    distributed by (airport_code);

insert into bookings.airports_data (select * from bookings.pxf_airports_data);

-- select * from bookings.airports_data;
-- select count(*) from bookings.airports_data;

-- drop table bookings.bookings;
create table bookings.bookings(                       -- 2'111'110 записей
	book_ref     bpchar(6),     -- Booking number
	book_date    text,          -- Booking date
	total_amount numeric(10, 2) -- Total booking cost
	)
	with (appendoptimized = true)
    distributed by (book_ref);	

insert into bookings.bookings (select * from bookings.pxf_bookings);

-- select * from bookings.bookings;
-- select count(*) from bookings.bookings;

-- drop table bookings.flights;
create table bookings.flights(                        -- 214'867 записей
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
    with (appendoptimized = true, orientation = column)
    distributed by (flight_id);	

insert into bookings.flights (select * from bookings.pxf_flights);

-- select * from bookings.flights;
-- select count(*) from bookings.flights;

-- drop table bookings.seats;
create table bookings.seats(                          -- 1'339 записей
	aircraft_code   bpchar(3),   -- Aircraft code, IATA
	seat_no         varchar(4),  -- Seat number
	fare_conditions varchar(10)  -- Travel class
	)
	with (appendoptimized = true)
    distributed by (aircraft_code, seat_no);	

insert into bookings.seats (select * from bookings.pxf_seats);

-- select * from bookings.seats;
-- select count(*) from bookings.seats;

-- drop table bookings.tickets;
create table bookings.tickets(                        -- 2'949'857 записей
	ticket_no      bpchar(13),  -- Ticket number
	book_ref       bpchar(6),   -- Booking number
	passenger_id   varchar(20), -- Passenger ID
	passenger_name text,        -- Passenger name
	contact_data   jsonb        -- Passenger contact information
	)
	with (appendoptimized = true)
    distributed by (ticket_no);	

insert into bookings.tickets (select * from bookings.pxf_tickets);

-- select * from bookings.tickets;
-- select count(*) from bookings.tickets;

-- drop table bookings.ticket_flights;
create table bookings.ticket_flights(                 -- 8'391'852 записей
	ticket_no       bpchar(13),    -- Ticket number
	flight_id       int4,          -- Flight ID
	fare_conditions varchar(10),   -- Travel class
	amount          numeric(10, 2) -- Travel cost
	)
	with (appendoptimized = true)
    distributed by (ticket_no, flight_id);	

insert into bookings.ticket_flights (select * from bookings.pxf_ticket_flights);

-- select * from bookings.ticket_flights;
-- select count(*) from bookings.ticket_flights;

-- drop table bookings.boarding_passes;
create table bookings.boarding_passes(                -- 7'925'812 записей
	ticket_no   bpchar(13), -- Ticket number
	flight_id   int4,       -- Flight ID
	boarding_no int4,       -- Boarding pass number
	seat_no     varchar(4)  -- Seat number
	)
	with (appendoptimized = true)
    distributed by (ticket_no, flight_id);	

insert into bookings.boarding_passes (select * from bookings.pxf_boarding_passes);

-- select * from bookings.boarding_passes;
-- select count(*) from bookings.boarding_passes;
