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