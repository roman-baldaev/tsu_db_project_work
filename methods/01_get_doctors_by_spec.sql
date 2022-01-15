CREATE OR REPLACE PROCEDURE P_list_of_doctors_by_specialization(spec_name TEXT,
                                hospital_id INTEGER DEFAULT NULL, clinic_id INTEGER DEFAULT NULL)
AS
$$
    DECLARE
        DELIMITER CONSTANT TEXT := '------------------------------------------------------';
        org_id INTEGER;
        _org_table TEXT;
        _contracts_table TEXT;
        _org_id_column TEXT;
        temprow RECORD;
        _spec_id INTEGER;
        cmd TEXT;
        report TEXT := DELIMITER || E'\n';
        params INTEGER[];
    BEGIN
        SELECT id INTO _spec_id
        FROM specializations WHERE name=spec_name;
        IF _spec_id IS NULL THEN
            RAISE EXCEPTION no_data_found
                USING MESSAGE = 'non existing specialization';
        END IF;
        cmd := 'SELECT DISTINCT ON (doctors.id)
                doctors.id AS id, doctors.name || '' '' || doctors.last_name AS name
                FROM %s contracts_table
                INNER JOIN %s org ON org.id = contracts_table.%s
                INNER JOIN doctors ON doctors.id = contracts_table.doctor_id
                WHERE contracts_table.%s = $1[1] AND doctors.spec_id = $1[2];';
        IF hospital_id IS NOT NULL THEN
            org_id := hospital_id;
            _org_table := 'hospitals';
            _contracts_table := 'doctors_hospitals';
            _org_id_column := 'hospital_id';
        ELSE
            IF clinic_id IS NOT NULL THEN
                org_id := clinic_id;
                _org_table := 'clinics';
                _contracts_table := 'doctors_clinics';
                _org_id_column := 'clinic_id';
            END IF;
        END IF;

        IF hospital_id IS NULL AND clinic_id IS NULL THEN
            cmd := 'SELECT doctors.id, doctors.name || '' '' || doctors.last_name AS name
                    FROM doctors
                    LEFT JOIN doctors_hospitals dh ON doctors.id = dh.doctor_id
                    LEFT JOIN doctors_clinics dc ON dc.doctor_id = doctors.id
                    AND doctors.spec_id = $1[1];';
            params := ARRAY [_spec_id];
        ELSE
            cmd := FORMAT(cmd, _contracts_table, _org_table, _org_id_column, _org_id_column);
            params := ARRAY [org_id, _spec_id];
        END IF;

        FOR temprow IN EXECUTE cmd USING params
            LOOP
                report := report || temprow.id || ' ' || temprow.name;
                report := report || E'\n';
            END LOOP;
        report := report || DELIMITER;
        RAISE NOTICE '%', report;
    END;
$$ LANGUAGE plpgsql;
