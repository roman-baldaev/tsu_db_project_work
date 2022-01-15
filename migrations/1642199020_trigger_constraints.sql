/*
 В данном файле создаются сложные ограничения, раелизуемые с помощью триггеров.
*/
INSERT INTO specializations(id, name, can_operate, additional_payment, long_vacation)
    VALUES (1, 'хирург', TRUE, FALSE, FALSE),
           (2, 'стоматолог', TRUE, FALSE, FALSE),
           (3, 'гинеколог', TRUE, FALSE, FALSE),
           (4, 'рентгенолог', FALSE, TRUE, TRUE),
           (5, 'невропатолог', FALSE, TRUE, FALSE)
    ON CONFLICT DO NOTHING;
------------------------------------------------------------------------------------------------
/*
    1.  "хирурги, стоматологи и гинекологи могут проводить операции"
    Проверяем при добавлении значений в таблицы `in_operations_doctors` и `out_operations_doctors`

    Для проверки необходимы следующие данные:
    - Таблица специализаций
    - Несколько врачей с разными специализациями (которые могут и не могут проводить операции)

    - Создать операцию, а значит -
    создать больницу, пациента, лечение и, собственно, операцию

    Попытаться добавить к операции доктора который может провести операцию и того кто нет
*/
CREATE OR REPLACE FUNCTION F_check_access_to_operation()
RETURNS TRIGGER AS $$
DECLARE
    _spec_id INTEGER;
    _spec_name TEXT;
    _can_operate BOOL := FALSE;
BEGIN
    IF (TG_OP = 'UPDATE') THEN
        IF new.doctor_id IS NULL THEN
            new.doctor_id = old.doctor_id;
        END IF;
    END IF;
    -- найдем специализацию доктора (и проверим существование)
    SELECT spec_id INTO _spec_id
    FROM doctors WHERE id=new.doctor_id;
    IF _spec_id IS NULL THEN
        RAISE EXCEPTION no_data_found
            USING MESSAGE = 'non existing doctor';
    END IF;

    SELECT can_operate, name INTO _can_operate, _spec_name
    FROM specializations WHERE id=_spec_id;
    IF _spec_name IS NULL THEN
        RAISE EXCEPTION no_data_found
            USING MESSAGE = 'non existing specialization';
    END IF;

    IF NOT _can_operate THEN
        RAISE EXCEPTION '% cannot do operation', _spec_name;
    END IF;
    RETURN new;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER TR_check_access_to_in_operation
BEFORE INSERT OR UPDATE ON in_operations_doctors
FOR EACH ROW
EXECUTE PROCEDURE F_check_access_to_operation();

CREATE TRIGGER TR_check_access_to_out_operation
BEFORE INSERT OR UPDATE ON out_operations_doctors
FOR EACH ROW
EXECUTE PROCEDURE F_check_access_to_operation();

/*
    2.  "они же имеют такие характеристики, как число прове- денных операций, число операций с летальным исходом"
    Проверяем при добавлении значений в таблицу operations_stats
*/
-- можем использовать ту же функцию (F_check_access_to_operation)
CREATE TRIGGER TR_check_access_to_operation_stats
BEFORE INSERT OR UPDATE ON operations_stats
FOR EACH ROW
EXECUTE PROCEDURE F_check_access_to_operation();

------------------------------------------------------------------------------------------------
/*
    Проверка первых трех триггеров
*/
-- создадим хирурга
INSERT INTO doctors(name, last_name, patronymic, degree, title, spec_id)
VALUES ('Это', 'Для', 'Тестирования', 'candidate', 'docent', 1);

-- создадим рентегенолога
INSERT INTO doctors(name, last_name, patronymic, degree, title, spec_id)
VALUES ('Это', 'Для', 'Тестирования', 'candidate', 'docent', 4);

INSERT INTO operations_stats(id, doctor_id, number_of_operations, number_of_lethal_operations)
VALUES (1000, (SELECT id FROM doctors WHERE spec_id = 1 LIMIT 1), 10, 0);

SELECT * FROM operations_stats;

-- ошибка
INSERT INTO operations_stats(id, doctor_id, number_of_operations, number_of_lethal_operations)
VALUES (1001, (SELECT id FROM doctors WHERE spec_id = 4 LIMIT 1), 10, 0);

-- можем обновить
UPDATE operations_stats SET number_of_lethal_operations = 1 WHERE id = 1000;

SELECT * FROM operations_stats;

-- ошибка
UPDATE operations_stats
SET doctor_id = (SELECT id FROM doctors WHERE spec_id = 4 LIMIT 1)
WHERE id = 1;

DELETE FROM operations_stats WHERE id >= 1000;
DELETE FROM doctors
WHERE name='Это' AND last_name='Для' AND patronymic='Тестирования';
------------------------------------------------------------------------------------------------


------------------------------------------------------------------------------------------------
/*
    3.  "рентгенологи и стоматологи имеют коэффициент к зарплате за вредные условия труда, у рентгенологов и невропатологов более длительный отпуск"
    Проверяем при добавлении/обновлении значений в таблице `doctors_clinics` и `doctors_hospitals`
*/
CREATE OR REPLACE FUNCTION F_check_non_default_contract_conditions()
RETURNS TRIGGER AS $$
DECLARE
    DEFAULT_PAYMENT_RATIO CONSTANT DOUBLE PRECISION := 1.0;
    DEFAULT_VACATION_DAYS CONSTANT INTEGER := 28;
    _additional_payment BOOL := FALSE;
    _long_vacation BOOL := FALSE;
    _spec_id INTEGER;
    _spec_name TEXT;
BEGIN
    IF (TG_OP = 'UPDATE') THEN
        IF new.doctor_id IS NULL THEN
            new.doctor_id = old.doctor_id;
        END IF;
    END IF;
    -- найдем специализацию доктора (и проверим существование)
    SELECT spec_id INTO _spec_id
    FROM doctors WHERE id=new.doctor_id;
    IF _spec_id IS NULL THEN
        RAISE EXCEPTION no_data_found
            USING MESSAGE = 'non existing doctor';
    END IF;

    -- получим необходимую информацию о специализации
    SELECT additional_payment, long_vacation, name INTO _additional_payment, _long_vacation, _spec_name
    FROM specializations WHERE id=_spec_id;
    IF _spec_name IS NULL THEN
        RAISE EXCEPTION no_data_found
            USING MESSAGE = 'non existing specialization';
    END IF;

    -- проверка на повышенный коэффициент
    IF (new.payment_ratio IS NOT NULL) AND (new.payment_ratio > DEFAULT_PAYMENT_RATIO) THEN
        IF NOT _additional_payment THEN
            RAISE EXCEPTION '% cannot have an increased payment ratio', _spec_name;
        END IF;
    END IF;

    -- проверка на увеличенное число дней отпуска
    IF (new.vacation_days IS NOT NULL) AND (new.vacation_days > DEFAULT_VACATION_DAYS) THEN
        IF NOT _long_vacation THEN
            RAISE EXCEPTION '% cannot have extended vacation', _spec_name;
        END IF;
    END IF;
    RETURN new;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER TR_check_non_default_contract_conditions_in_clinics
BEFORE INSERT OR UPDATE ON doctors_clinics
FOR EACH ROW
EXECUTE PROCEDURE F_check_non_default_contract_conditions();

CREATE TRIGGER TR_check_non_default_contract_conditions_in_hospitals
BEFORE INSERT OR UPDATE ON doctors_hospitals
FOR EACH ROW
EXECUTE PROCEDURE F_check_non_default_contract_conditions();

/*
    Проверка триггеров (на примере TR_check_non_default_contract_conditions_in_hospitals)
*/
-- создадим больницу
INSERT INTO hospitals(id, name, address, phone)
VALUES (1000, 'Первая городская больница', 'ул. Тестировочная', '555-222');

-- создадим должность
INSERT INTO doctor_posts(id, name) VALUES (1000, 'Врач');

-- создадим хирурга
INSERT INTO doctors(id, name, last_name, patronymic, degree, title, spec_id)
VALUES (1000, 'Это', 'Для', 'Тестирования', 'candidate', 'docent', 1);

-- создадим рентегенолога
INSERT INTO doctors(id, name, last_name, patronymic, degree, title, spec_id)
VALUES (1001, 'Это', 'Для', 'Тестирования', 'candidate', 'docent', 4);

-- ОШИБКА - контракт хирурга с повышенно коэффициентов
INSERT INTO doctors_hospitals(id, doctor_id, hospital_id, post_id, "from", salary, payment_ratio)
VALUES (1000, 1000, 1000, 1000, CURRENT_DATE, 100000, 1.5);

-- ОШИБКА  хирурга с увеличенным отпуском
INSERT INTO doctors_hospitals(id, doctor_id, hospital_id, post_id, "from", salary, vacation_days)
VALUES (1000, 1000, 1000, 1000, CURRENT_DATE, 100000, 35);

-- можем добавить хирурга со значениями по умолчанию
INSERT INTO doctors_hospitals(id, doctor_id, hospital_id, post_id, "from", salary)
VALUES (1000, 1000, 1000, 1000, CURRENT_DATE, 100000);

-- ОШИБКА - попытка увеличить дни отпуска хирурга
UPDATE doctors_hospitals
SET vacation_days = 35
WHERE id = 1000;

-- можем добавить рентгенолога с повышенными значениями
INSERT INTO doctors_hospitals(id, doctor_id, hospital_id, post_id, "from", salary, payment_ratio, vacation_days)
VALUES (1001, 1001, 1000, 1000, CURRENT_DATE, 100000, 1.5, 35);

DELETE FROM doctors_hospitals WHERE id >= 1000;
DELETE FROM hospitals WHERE id >= 1000;
DELETE FROM doctor_posts WHERE id >= 1000;
DELETE FROM doctors WHERE id >= 1000;
------------------------------------------------------------------------------------------------


------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------
/*
    4.  " Степень доктора медицинских наук дает право на присво- ение звания профессора, а степень кандидата медицинских наук на присвоение звания доцента"
    Проверяем при добавлении/обновлении значений в таблице `doctors`
*/
CREATE OR REPLACE FUNCTION F_check_correct_degree_for_title()
RETURNS TRIGGER AS $$
BEGIN
    IF new.title IS NULL THEN
        IF (TG_OP = 'INSERT') THEN
            -- просто ставим значение по умолчанию
            new.title = 'none';
        END IF;
        RETURN new;
    END IF;

    IF (TG_OP = 'UPDATE') THEN
        IF new.degree IS NULL THEN
            new.degree = old.degree;
        END IF;
    END IF;
    -- проверка на профессора
    IF new.title = 'professor' THEN
        IF new.degree != 'doctor' THEN
            RAISE EXCEPTION '% cannot be %', new.degree, new.title;
        END IF;
    END IF;
    -- доцента
    IF new.title = 'docent' THEN
        IF new.degree != 'doctor' AND new.degree != 'candidate' THEN
            RAISE EXCEPTION '% cannot be %', new.degree, new.title;
        END IF;
    END IF;
    RETURN new;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER TR_check_correct_degree_for_title
BEFORE INSERT OR UPDATE ON doctors
FOR EACH ROW
EXECUTE PROCEDURE F_check_correct_degree_for_title();

/*
    Проверка триггера
*/
-- кандидат - доцент
INSERT INTO doctors(id, name, last_name, patronymic, degree, title, spec_id)
VALUES (1000, 'Это', 'Для', 'Тестирования', 'candidate', 'docent', 1);

-- доктор доцент
INSERT INTO doctors(id, name, last_name, patronymic, degree, title, spec_id)
VALUES (1001, 'Это', 'Для', 'Тестирования', 'doctor', 'docent', 1);

-- доктор профессор
INSERT INTO doctors(id, name, last_name, patronymic, degree, title, spec_id)
VALUES (1002, 'Это', 'Для', 'Тестирования', 'doctor', 'docent', 1);

-- ОШИБКА - кандидат профессор
INSERT INTO doctors(id, name, last_name, patronymic, degree, title, spec_id)
VALUES (1003, 'Это', 'Для', 'Тестирования', 'candidate', 'professor', 1);

DELETE FROM doctors WHERE id >= 1000;
------------------------------------------------------------------------------------------------


------------------------------------------------------------------------------------------------
