--Больницы
---------------------------------------------------------------------------
INSERT INTO hospitals (name, address, phone) -- (phones?)
VALUES('Городская больница №1', 'улица Герасименко, 105', '+73822112233');

INSERT INTO hospitals (name, address, phone)
VALUES('Городская больница №2', 'улица Клюева, 82', '+73822334455');

--Поликлиники
---------------------------------------------------------------------------
INSERT INTO polyclinics (hospital_id, name, address, phone)
VALUES(1, 'Поликлиника №1', 'улица Алеутская, 88', '+73822990011');

INSERT INTO polyclinics (hospital_id, name, address, phone)
VALUES(2, 'Поликлиника №2', 'проспект Кирова, 104', '+73822776600');

---------------------------------------------------------------------------

-- Врачи
---------------------------------------------------------------------------
INSERT INTO doctors (name, last_name, patronymic, degree, title, spec_id, birth_date, works_since, alma_mater)
VALUES('Алексей', 'Смирнов', 'Александрович', 'doctor', 'professor', 1, '1977-10-01', '2006-05-16', 'че');

INSERT INTO doctors (name, last_name, patronymic, degree, title, spec_id, birth_date, works_since, alma_mater)
VALUES('Владимир', 'Пугачев', 'Владимирович', 'none', 'none', 2, '1989-04-06', '2018-11-11', 'че');

INSERT INTO doctors (name, last_name, patronymic, degree, title, spec_id, birth_date, works_since, alma_mater)
VALUES('Максим', 'Томский', 'Евгеньевич', 'candidate', 'docent', 3, '1990-01-21', '2012-12-02', 'че');

INSERT INTO doctors (name, last_name, patronymic, degree, title, spec_id, birth_date, works_since, alma_mater)
VALUES('Денис', 'Московский', 'Алексеевич', 'candidate', 'professor', 4, '1984-06-05', '2013-01-24', 'че');

-- Специализации
----------------------------------------------------------------------------
INSERT INTO specializations (id, name, can_operate, additional_payment, long_vacation)
VALUES(1, 'Хирург', true, true, true);

INSERT INTO specializations (id, name, can_operate, additional_payment, long_vacation)
VALUES(2, 'Невролог', false, false, true);

INSERT INTO specializations (id, name, can_operate, additional_payment, long_vacation)
VALUES(3, 'Ревматолог', true, false, false);

INSERT INTO specializations (id, name, can_operate, additional_payment, long_vacation)
VALUES(4, 'Окулист', true, false, false);

INSERT INTO specializations (id, name, can_operate, additional_payment, long_vacation)
VALUES(5, 'Венеролог', false, true, false);

INSERT INTO specializations (id, name, can_operate, additional_payment, long_vacation)
VALUES(6, 'Дерматолог', false, false, false);

INSERT INTO specializations (id, name, can_operate, additional_payment, long_vacation)
VALUES(7, 'Психиатр', false, false, true);

INSERT INTO specializations (id, name, can_operate, additional_payment, long_vacation)
VALUES(8, 'Психолог', false, false, true);