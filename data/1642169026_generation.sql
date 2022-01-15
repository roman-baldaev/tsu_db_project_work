-- Больницы (что такое phones?)
DO $$
DECLARE
	smth varchar(100);
	my_name text;
	my_adress text; 
	my_phone text;
BEGIN
	FOR i IN 1 .. 6
	LOOP
		SELECT CONCAT('Городская больница №', CAST(ROUND(random()*14+1) AS text)) INTO my_name;
		SELECT CONCAT(adress, ', ', ROUND(random()*(111-1)+1)) INTO my_adress
		FROM help WHERE random() > 0.92 LIMIT 1;
		SELECT CONCAT('+73822', CAST(FLOOR(random()*(1000000-100000)+100000) AS text)) INTO my_phone;
		INSERT INTO hospitals (name, address, phone)
		VALUES(my_name, my_adress, my_phone);
	END LOOP;
END $$;

select * from hospitals;
delete from hospitals;

------------------------------------------------------------------------------------------------------------
CREATE TABLE "Даты" -- Вспомогательная таблица с датами
(  "Даты_и_время" TIMESTAMP WITHOUT TIME ZONE NOT NULL
 , "Даты" DATE NOT NULL
 , "Время" TIME WITHOUT TIME ZONE NOT NULL
);

-- Даты (надо подправить, полностью скопировал с первой индивидуалки своей)
DO $$
DECLARE
	day1 INTEGER;
	smth varchar(100);
	my_date TIMESTAMP WITHOUT TIME ZONE;
	my_d DATE;
	my_t TIME WITHOUT TIME ZONE;
BEGIN
	FOR i IN 1 .. 60
	LOOP
		SELECT (random() + 11) INTO day1;
		SELECT make_timestamp(2021, CAST(random() + 11 AS INTEGER), CAST((random()*29 + 1) AS INTEGER), CAST(random()*24 AS INTEGER), 0, 0) INTO my_date;
		SELECT make_date(2021, CAST(random() + 11 AS INTEGER), CAST((random()*29 + 1) AS INTEGER)) INTO my_d;
		SELECT make_time(CAST(random()*24 AS INTEGER), 0, 0) INTO my_t;
		-- Через селект в инсерте почему-то не работает (пустой результат)
		--RAISE NOTICE '%', my_date;
		INSERT INTO "Даты" ("Даты_и_время", "Даты", "Время")
		VALUES(my_date, my_d, my_t);
	END LOOP;
END $$;

---------------------------------------------------------------------------------------------------------------

select * from russian_names;
select * from russian_surnames;
-----------------------------------------------------------------------------------------------------------

-- Поликлиники (засовывает нули в hospital_id пока что)
-- не знаю почему
DO $$
DECLARE
	smth varchar(100);
	hosp_id integer;
	my_name text;
	my_adress text; 
	my_phone text;
BEGIN
	FOR i IN 1 .. 6
	LOOP
		SELECT id INTO hosp_id
		FROM hospitals WHERE random() > 0.8;
		SELECT CONCAT('Поликлиника №', CAST(ROUND(random()*14+1) AS text)) INTO my_name;
		SELECT CONCAT(adress, ', ', ROUND(random()*(111-1)+1)) INTO my_adress
		FROM help WHERE random() > 0.92 LIMIT 1;
		SELECT CONCAT('+73822', CAST(FLOOR(random()*(1000000-100000)+100000) AS text)) INTO my_phone;
		INSERT INTO polyclinics (hospital_id, name, address, phone)
		VALUES(hosp_id, my_name, my_adress, my_phone);
	END LOOP;
END $$;

SELECT * from polyclinics;
delete from polyclinics;

SELECT * from hospitals;
