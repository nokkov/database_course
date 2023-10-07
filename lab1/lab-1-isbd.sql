CREATE TABLE spaceship_types (
    type_id SERIAL PRIMARY KEY,
    type_name VARCHAR(50) NOT NULL,
	
	CHECK (type_name != '')
);

INSERT INTO spaceship_types (type_name) VALUES ('Transport');
INSERT INTO spaceship_types (type_name) VALUES ('Combat');
INSERT INTO spaceship_types (type_name) VALUES ('Medical');

CREATE TABLE ranks (
	rank_id serial PRIMARY KEY,
	rank_name VARCHAR(50) NOT NULL,
	approval_date date NOT NULL
	
	CHECK (rank_name != '')
);

INSERT INTO ranks (rank_name, approval_date) VALUES ('SOLDIER', CURRENT_DATE);
INSERT INTO ranks (rank_name, approval_date) VALUES ('SERGEANT', '1985-05-12');
INSERT INTO ranks (rank_name, approval_date) VALUES ('CAPTAIN', '1970-01-01');
INSERT INTO ranks (rank_name, approval_date) VALUES ('GENERAL', '1910-02-19');
INSERT INTO ranks (rank_name, approval_date) VALUES ('DARTH VADER', '1875-10-16');


CREATE TABLE occupations (
	occupation_id serial PRIMARY KEY,
	occupation_name VARCHAR(50) UNIQUE NOT NULL,
	occupation_desc VARCHAR(500) UNIQUE NOT NULL,
	
	CHECK (occupation_name !=''),
	CHECK (occupation_desc !='')
);

INSERT INTO occupations (occupation_name, occupation_desc) VALUES ('cook', 'cooks delicious food');
INSERT INTO occupations (occupation_name, occupation_desc) VALUES ('locksmith', 'fixes toilets');
INSERT INTO occupations (occupation_name, occupation_desc) VALUES ('electrician', 'has no relation to Germany');
INSERT INTO occupations (occupation_name, occupation_desc) VALUES ('barman', 'gets people drunk professionally');
INSERT INTO occupations (occupation_name, occupation_desc) VALUES ('dealer', 'and again this is not what you might think');

CREATE TABLE planets (
	planet_id serial PRIMARY KEY,
	name VARCHAR(50) NOT NULL,
	radius BIGINT NOT NULL,
	weight BIGINT NOT NULL,
	
	CHECK (radius > 0),
	CHECK (weight > 0)
);

INSERT INTO planets (name, radius, weight) VALUES ('Jupiter', 699111, 189827);
INSERT INTO planets (name, radius, weight) VALUES ('Mars', 3389, 6.3923);
INSERT INTO planets (name, radius, weight) VALUES ('Mercury',  2439, 3.28523);
INSERT INTO planets (name, radius, weight) VALUES ('Venus', 6051, 4.86724);


CREATE TABLE satellites (
	satellite_id serial PRIMARY KEY,
	satellite_name VARCHAR(50) NOT NULL,
	planet_id INTEGER NOT NULL REFERENCES planets(planet_id) ON DELETE CASCADE ON UPDATE CASCADE,
	
	CONSTRAINT not_empty_name CHECK (satellite_name != '')
);

INSERT INTO satellites (satellite_name, planet_id) VALUES ('Jupiter Satellite 1', (SELECT planet_id FROM planets WHERE name = 'Jupiter'));
INSERT INTO satellites (satellite_name, planet_id) VALUES ('Mars Satellite 1', (SELECT planet_id FROM planets WHERE name = 'Mars'));
INSERT INTO satellites (satellite_name, planet_id) VALUES ('Mercury Satellite 1', (SELECT planet_id FROM planets WHERE name = 'Mercury'));
INSERT INTO satellites (satellite_name, planet_id) VALUES ('Venus Satellite 1', (SELECT planet_id FROM planets WHERE name = 'Venus'));


CREATE TABLE spaceships (
	spaceship_id serial PRIMARY KEY,
	spaceship_name VARCHAR(50) NOT NULL,
	spaceship_type INTEGER REFERENCES spaceship_types(type_id) ON DELETE CASCADE ON UPDATE CASCADE,
	people_capacity INTEGER NOT NULL,
	fuel_reserve INTEGER NOT NULL,
	max_speed INTEGER NOT NULL,
	
	CHECK (spaceship_name != ''),
	CHECK (people_capacity > 1),
	CHECK (fuel_reserve > 1),
	CHECK (max_speed > 1)
);

INSERT INTO spaceships (spaceship_name, spaceship_type, people_capacity, fuel_reserve, max_speed) VALUES ('Discovery', 1, 100, 10000, 3200);
INSERT INTO spaceships (spaceship_name, spaceship_type, people_capacity, fuel_reserve, max_speed) VALUES ('Leonov', 1, 150, 10000, 3200);
INSERT INTO spaceships (spaceship_name, spaceship_type, people_capacity, fuel_reserve, max_speed) VALUES ('DEATH STAR', 2, 5000, 30332000, 2000);
INSERT INTO spaceships (spaceship_name, spaceship_type, people_capacity, fuel_reserve, max_speed) VALUES ('Chehov', 3, 200, 10000, 3300);
INSERT INTO spaceships (spaceship_name, spaceship_type, people_capacity, fuel_reserve, max_speed) VALUES ('Little Boy', 2, 1, 3250, 800);

CREATE FUNCTION check_spaceship_capacity() RETURNS TRIGGER AS $$
		BEGIN
			IF (SELECT COUNT(*) FROM astronauts WHERE spaceship_id = NEW.spaceship_id) >= (SELECT people_capacity FROM spaceships WHERE spaceship_id = NEW.spaceship_id) THEN
				RAISE EXCEPTION 'Cant add a new astronaut to the ship - the ship is full!';
			END IF;
			RETURN NEW;			
		END;
$$ LANGUAGE PLPGSQL;

CREATE TRIGGER check_astronaut_insert
	BEFORE INSERT ON astronauts
	FOR EACH ROW
	EXECUTE FUNCTION check_spaceship_capacity();


CREATE TABLE astronauts (
	astronaut_id serial PRIMARY KEY,
	astronaut_name VARCHAR(50) NOT NULL,
	astronaut_surname VARCHAR(50) NOT NULL,
	astronaut_age SMALLINT NOT NULL,
	
	rank_id INTEGER REFERENCES ranks(rank_id) ON UPDATE CASCADE,
	occupation_id INTEGER REFERENCES occupations(occupation_id) ON UPDATE CASCADE,
	spaceship_id INTEGER REFERENCES spaceships(spaceship_id) ON UPDATE CASCADE,

	CHECK (astronaut_name != ''),
	CHECK (astronaut_surname != ''),
	CHECK (astronaut_age > 0 and astronaut_age < 170)
);

INSERT INTO astronauts (astronaut_name, astronaut_surname, astronaut_age, rank_id, occupation_id, spaceship_id) VALUES ('John', 'Lennon', 40, 1, 1, 1);
INSERT INTO astronauts (astronaut_name, astronaut_surname, astronaut_age, rank_id, occupation_id, spaceship_id) VALUES ('Paul', 'McCartney', 81, 4, 2, 1);
INSERT INTO astronauts (astronaut_name, astronaut_surname, astronaut_age, rank_id, occupation_id, spaceship_id) VALUES ('George', 'Harrison', 58, 2, 2, 1);
INSERT INTO astronauts (astronaut_name, astronaut_surname, astronaut_age, rank_id, occupation_id, spaceship_id) VALUES ('Ringo', 'Starr', 83, 3, 3, 1);
INSERT INTO astronauts (astronaut_name, astronaut_surname, astronaut_age, rank_id, occupation_id, spaceship_id) VALUES ('Till', 'Lindemann', 60, 4, 3, 5);

CREATE TABLE space_flights (
	flight_id serial PRIMARY KEY,
	spaceship_id INTEGER REFERENCES spaceships(spaceship_id) NOT NULL,
	planet_id_from INTEGER REFERENCES planets(planet_id) NOT NULL,
	planet_id_to INTEGER REFERENCES planets(planet_id) NOT NULL
);

INSERT INTO space_flights (spaceship_id, planet_id_from, planet_id_to) VALUES (1, 1, 2);
INSERT INTO space_flights (spaceship_id, planet_id_from, planet_id_to) VALUES (2, 2, 3);
INSERT INTO space_flights (spaceship_id, planet_id_from, planet_id_to) VALUES (3, 3, 4);

