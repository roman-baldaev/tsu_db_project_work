-- Вся генерация имеет шанс не сработать, т.к есть ограничение на уникальность названия.
-- И получается, что когда рандом среди 6 цифр выдает хотя бы две одинаковых, происходит ошибка.
-- Предлагаю не заморачиваться и оставить так, просто пытаться генерить данные до тех пор, пока не сгенерит
-- все цифры разными (это не редко и не долго)

-- Больницы (что такое phones?)
DO $$
DECLARE
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
-- Даты (заполняет вспомогательную таблицу dates_table)
DO $$
DECLARE
	day1 INTEGER;
	my_date TIMESTAMP WITHOUT TIME ZONE;
	my_d DATE;
	my_t TIME WITHOUT TIME ZONE;
BEGIN
	FOR i IN 1 .. 10000
	LOOP
		--SELECT (random() + 11) INTO day1;
		SELECT make_timestamp(CAST(1960 + random()*63 AS integer), CAST(random()*11 + 1 AS INTEGER), CAST((random()*27 + 1) AS INTEGER), CAST(random()*24 AS INTEGER), 0, 0) INTO my_date;
		SELECT make_date(CAST(1960 + random()*63 AS integer), CAST(random()*11 + 1 AS INTEGER), CAST((random()*27 + 1) AS INTEGER)) INTO my_d;
		SELECT make_time(CAST(random()*24 AS INTEGER), 0, 0) INTO my_t;
		INSERT INTO dates_table (dates_and_times, dates, times)
		VALUES(my_date, my_d, my_t);
	END LOOP;
END $$;
select * from dates_table;
delete from dates_table;

---------------------------------------------------------------------------------------------------------------
-- Поликлиники
-- Иногда будет засовывать нули при генерации, просто прогнать надо будет если вдруг сгенерит
DO $$
DECLARE
	hosp_id integer;
	my_name text;
	my_adress text; 
	my_phone text;
BEGIN
	FOR i IN 1 .. 6
	LOOP
		SELECT id INTO hosp_id
		FROM hospitals WHERE random() > 0.7;
		
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

-------------------------------------------------------------------------------------------------------------
-- doctors
-- нет поля алма матер и нет разбиения по полу (винегрет)
DO $$
DECLARE
	my_name text;
	my_last_name text;
	my_patronymic text;
	my_degree text; 
	my_title text;
	my_spec_id integer;
	my_birth_date date;
	my_works_since date;
	my_alma_mater text;
BEGIN
	FOR i IN 1 .. 6
	LOOP
		SELECT name INTO my_name
		FROM russian_names WHERE random() > 0.9999 LIMIT 1;
		
		SELECT surname INTO my_last_name
		FROM russian_surnames WHERE random() > 0.9999 LIMIT 1;
		
		SELECT patronymic INTO my_patronymic
		FROM russian_patronymics WHERE random() > 0.8 LIMIT 1;
		
		SELECT id INTO my_spec_id
		FROM specializations WHERE random() > 0.7 LIMIT 1;
		
		SELECT dates INTO my_birth_date
		FROM dates_table WHERE random() > 0.9 AND EXTRACT(YEAR FROM dates) <= '2000';
		
		SELECT dates INTO my_works_since
		FROM dates_table WHERE random() > 0.9 AND EXTRACT(YEAR FROM dates) > '2000';
		
		INSERT INTO doctors (name, last_name, patronymic, degree, title, spec_id, birth_date, works_since, alma_mater)
		VALUES(my_name, my_last_name, my_patronymic, 'doctor', 'professor', my_spec_id, my_birth_date, my_works_since, 'че');
	END LOOP;
END $$;

SELECT * FROM doctors;
delete from doctors;

-------------------------------------------------------------------------------------------------------------
-- doctors_hospitals
-- Тоже не сразу генерит (не страшно надеюсь) 
DO $$
DECLARE
	doc_id integer;
	hosp_id integer;
	my_agreement text;
	my_post_id integer;
	my_from date; 
	my_to date;
	my_salary integer;
	my_working_rate double precision;
BEGIN
	FOR i IN 1 .. 6
	LOOP
		SELECT id INTO doc_id
		FROM doctors WHERE random() > 0.5 LIMIT 1;
		
		SELECT id INTO hosp_id
		FROM hospitals WHERE random() > 0.5 LIMIT 1;
		
		SELECT id INTO my_post_id
		FROM doctor_posts WHERE random() > 0.5 LIMIT 1;
		
		SELECT dates INTO my_from
		FROM dates_table WHERE random() > 0.5 AND EXTRACT(YEAR FROM dates) <= '2021' LIMIT 1;
		
		SELECT dates INTO my_to
		FROM dates_table WHERE random() > 0.5 AND EXTRACT(YEAR FROM dates) > '2021' LIMIT 1;
		
		SELECT random()*(100000-10000)+10000 INTO my_salary;
		
		SELECT CAST(random()*9+1 AS integer) INTO my_working_rate;
		
		INSERT INTO doctors_hospitals (doctor_id, hospital_id, agreement, post_id, "from", "to", salary, working_rate)
		VALUES(doc_id, hosp_id, ' ', my_post_id, my_from, my_to, my_salary, my_working_rate);
	END LOOP;
END $$;


select * from doctors_hospitals;
delete from doctors_hospitals;

-------------------------------------------------------------------------------------------------------------
-- doctors_clinics
DO $$
DECLARE
	doc_id integer;
	clin_id integer;
	my_agreement text;
	my_post_id integer;
	my_from date; 
	my_to date;
	my_salary integer;
	my_working_rate double precision;
BEGIN
	FOR i IN 1 .. 6
	LOOP
		SELECT id INTO doc_id
		FROM doctors WHERE random() > 0.5 LIMIT 1;
		
		SELECT id INTO clin_id
		FROM polyclinics WHERE random() > 0.5 LIMIT 1;
		
		SELECT id INTO my_post_id
		FROM doctor_posts WHERE random() > 0.5 LIMIT 1;
		
		SELECT dates INTO my_from
		FROM dates_table WHERE random() > 0.5 AND EXTRACT(YEAR FROM dates) <= '2021' LIMIT 1;
		
		SELECT dates INTO my_to
		FROM dates_table WHERE random() > 0.5 AND EXTRACT(YEAR FROM dates) > '2021' LIMIT 1;
		
		SELECT random()*(100000-10000)+10000 INTO my_salary;
		
		SELECT CAST(random()*9+1 AS integer) INTO my_working_rate;
		
		INSERT INTO doctors_clinics (doctor_id, clinic_id, agreement, post_id, "from", "to", salary, working_rate)
		VALUES(doc_id, clin_id, ' ', my_post_id, my_from, my_to, my_salary, my_working_rate);
	END LOOP;
END $$;


select * from doctors_clinics;
delete from doctors_clinics;

---------------------------------------------------------------------------------------------------------------
-- buildings
DO $$
DECLARE
	hosp_id integer;
	my_adress text; 
	my_phone text;
BEGIN
	FOR i IN 1 .. 6
	LOOP
		SELECT id INTO hosp_id
		FROM hospitals WHERE random() > 0.7 LIMIT 1;
		
		SELECT CONCAT(adress, ', ', ROUND(random()*(111-1)+1)) INTO my_adress
		FROM help WHERE random() > 0.92 LIMIT 1;
		
		SELECT CONCAT('+73822', CAST(FLOOR(random()*(1000000-100000)+100000) AS text)) INTO my_phone;
		
		INSERT INTO buildings (hospital_id, address, phone)
		VALUES(hosp_id, my_adress, my_phone);
	END LOOP;
END $$;

select * from buildings;
delete from buildings;

---------------------------------------------------------------------------------------------------------------
-- departments
DO $$
DECLARE
	my_building_id integer;
	my_spec_id integer; 
	my_phone text;
BEGIN
	FOR i IN 1 .. 6
	LOOP
		SELECT id INTO my_building_id
		FROM buildings WHERE random() > 0.7 LIMIT 1;
		
		SELECT id INTO my_spec_id
		FROM dep_specializations WHERE random() > 0.7 LIMIT 1;
		
		SELECT CONCAT('+73822', CAST(FLOOR(random()*(1000000-100000)+100000) AS text)) INTO my_phone;
		
		INSERT INTO departments (building_id, spec_id, phone)
		VALUES(my_building_id, my_spec_id, my_phone);
	END LOOP;
END $$;

select * from departments;
delete from departments;

---------------------------------------------------------------------------------------------------------------
-- wards
DO $$
DECLARE
	my_department_id integer;
	my_number_of_beds integer; 
BEGIN
	FOR i IN 1 .. 6
	LOOP
		SELECT id INTO my_department_id
		FROM departments WHERE random() > 0.7 LIMIT 1;
		
		SELECT random()*19+1 INTO my_number_of_beds;
		
		INSERT INTO wards (department_id, number_of_beds)
		VALUES(my_department_id, my_number_of_beds);
	END LOOP;
END $$;

select * from wards;
delete from wards;