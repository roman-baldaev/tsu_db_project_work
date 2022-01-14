CREATE TYPE "doctor_titles" AS ENUM (
  'none',
  'docent',
  'professor'
);

CREATE TYPE "doctor_degrees" AS ENUM (
  'none',
  'candidate',
  'doctor'
);

CREATE TABLE "hospitals" (
  "id" SERIAL PRIMARY KEY,
  "name" text UNIQUE NOT NULL,
  "address" text NOT NULL,
  "phone" text UNIQUE NOT NULL,
  "phones" text NOT NULL DEFAULT '[]'
);

CREATE TABLE "buildings" (
  "id" SERIAL PRIMARY KEY,
  "hospital_id" int NOT NULL,
  "address" text NOT NULL,
  "phone" text NOT NULL,
  CONSTRAINT "fk_hospital_id_buildings" FOREIGN KEY ("hospital_id") REFERENCES "hospitals" ("id")
);

CREATE TABLE "dep_specializations" (
  "id" SERIAL PRIMARY KEY,
  "name" text UNIQUE NOT NULL
);

CREATE TABLE "departments" (
  "id" SERIAL PRIMARY KEY,
  "building_id" int NOT NULL,
  "spec_id" int NOT NULL, -- было text почему-то, компилятор ругается
  "phone" text NOT NULL,
  CONSTRAINT "fk_building_id_departments" FOREIGN KEY ("building_id") REFERENCES "buildings" ("id"),
  CONSTRAINT "fk_spec_id_departments" FOREIGN KEY ("spec_id") REFERENCES "dep_specializations" ("id")
);

CREATE TABLE "wards" (
  "id" SERIAL PRIMARY KEY,
  "department_id" int NOT NULL,
  "number_of_beds" int NOT NULL,
  "resuscitation" bool NOT NULL DEFAULT false,
  CONSTRAINT "fk_department_id_wards" FOREIGN KEY ("department_id") REFERENCES "departments" ("id")
);

CREATE TABLE "polyclinics" (
  "id" SERIAL PRIMARY KEY,
  "hospital_id" int,
  "name" text UNIQUE NOT NULL,
  "address" text NOT NULL,
  "phone" text UNIQUE NOT NULL,
  CONSTRAINT "fk_hospital_id_polyclinics" FOREIGN KEY ("hospital_id") REFERENCES "hospitals" ("id")
);

CREATE TABLE "clinic_rooms" (
  "id" SERIAL PRIMARY KEY,
  "clinic_id" int NOT NULL,
  "number" text NOT NULL,
  "floor" int NOT NULL,
  "name" text NOT NULL,
  CONSTRAINT "fk_clinic_id_clinic_rooms" FOREIGN KEY ("clinic_id") REFERENCES "polyclinics" ("id")
);

CREATE TABLE "lab_specializations" (
  "id" SERIAL PRIMARY KEY,
  "name" text UNIQUE NOT NULL
);

CREATE TABLE "laboratories" (
  "id" int PRIMARY KEY,
  "name" text NOT NULL,
  "phone" text UNIQUE NOT NULL,
  "address" text NOT NULL
);

CREATE TABLE "lab_with_specialization" (
  "lab_id" int,
  "spec_id" int,
  CONSTRAINT "pk_lab_spec_id_lab_with_specialization" PRIMARY KEY ("lab_id", "spec_id"),
  CONSTRAINT "fk_lab_id_lab_with_specialization" FOREIGN KEY ("lab_id") REFERENCES "laboratories" ("id"),
  CONSTRAINT "fk_spec_id_lab_with_specialization" FOREIGN KEY ("spec_id") REFERENCES "lab_specializations" ("id")
);

CREATE TABLE "clinic_lab_agreements" (
  "id" int PRIMARY KEY,
  "clinic_id" int,
  "lab_id" int,
  "agreement" text,
  "from" date NOT NULL,
  "to" date,
  CONSTRAINT "fk_clinic_id_clinic_lab_agreements" FOREIGN KEY ("clinic_id") REFERENCES "polyclinics" ("id"),
  CONSTRAINT "fk_lab_id_clinic_lab_agreements" FOREIGN KEY ("lab_id") REFERENCES "laboratories" ("id")
);

CREATE TABLE "hospital_lab_agreements" (
  "id" int PRIMARY KEY,
  "hospital_id" int NOT NULL,
  "lab_id" int NOT NULL,
  "agreement" text,
  "from" date NOT NULL,
  "to" date,
  CONSTRAINT "fk_hospital_id_hospital_lab_agreements" FOREIGN KEY ("hospital_id") REFERENCES "hospitals" ("id"),
  CONSTRAINT "fk_lab_id_hospital_lab_agreements" FOREIGN KEY ("lab_id") REFERENCES "laboratories" ("id")
);

CREATE TABLE "specializations" (
  "id" int PRIMARY KEY,
  "name" text NOT NULL,
  "can_operate" boolean NOT NULL DEFAULT false,
  "additional_payment" boolean NOT NULL DEFAULT false,
  "long_vacation" boolean NOT NULL DEFAULT false
);

CREATE TABLE "doctors" (
  "id" SERIAL PRIMARY KEY,
  "name" text NOT NULL,
  "last_name" text NOT NULL,
  "patronymic" text,
  "degree" doctor_degrees,
  "title" doctor_titles NOT NULL,
  "spec_id" int NOT NULL,
  "birth_date" date,
  "works_since" date,
  "alma_mater" text,
  CONSTRAINT "fk_spec_id_doctors" FOREIGN KEY ("spec_id") REFERENCES "specializations" ("id")
);

CREATE TABLE "service_posts" (
  "id" SERIAL PRIMARY KEY,
  "name" text UNIQUE NOT NULL
);

CREATE TABLE "service_staff" (
  "id" SERIAL PRIMARY KEY,
  "name" text NOT NULL,
  "last_name" text NOT NULL,
  "patronymic" text,
  "post_id" int NOT NULL,
  "birth_date" date,
  CONSTRAINT "fk_post_id_service_staff" FOREIGN KEY ("post_id") REFERENCES "service_posts" ("id")
);

CREATE TABLE "operations_stats" (
  "id" int PRIMARY KEY,
  "doctor_id" int,
  "number_of_operations" int,
  "number_of_lethal_operations" int,
  CONSTRAINT "fk_doctor_id_operations_stats" FOREIGN KEY ("doctor_id") REFERENCES "doctors" ("id")
);

CREATE TABLE "doctor_posts" ( -- помимо специализации, заведующий отделением и тд
  "id" SERIAL PRIMARY KEY,
  "name" text UNIQUE NOT NULL
);

CREATE TABLE "doctors_clinics" (
  "id" SERIAL PRIMARY KEY,
  "doctor_id" int NOT NULL,
  "clinic_id" int NOT NULL,
  "agreement" text,
  "post_id" int NOT NULL,
  "from" date NOT NULL,
  "to" date,
  "salary" decimal NOT NULL,
  "working_rate" float NOT NULL DEFAULT 1,
  "payment_ratio" float NOT NULL DEFAULT 1,
  "vacation_days" int NOT NULL DEFAULT 28,
  CONSTRAINT "fk_doctor_id_doctors_clinics" FOREIGN KEY ("doctor_id") REFERENCES "doctors" ("id"),
  CONSTRAINT "fk_clinic_id_doctors_clinics" FOREIGN KEY ("clinic_id") REFERENCES "polyclinics" ("id"),
  CONSTRAINT "fk_post_id_doctors_clinics" FOREIGN KEY ("post_id") REFERENCES "doctor_posts" ("id")
);

CREATE TABLE "doctors_hospitals" (
  "id" SERIAL PRIMARY KEY,
  "doctor_id" int NOT NULL,
  "hospital_id" int NOT NULL,
  "agreement" text,
  "post_id" int NOT NULL,
  "from" date NOT NULL,
  "to" date,
  "salary" decimal NOT NULL,
  "working_rate" float NOT NULL DEFAULT 1,
  "payment_ratio" float NOT NULL DEFAULT 1,
  "vacation_days" int NOT NULL DEFAULT 28,
  CONSTRAINT "fk_doctor_id_doctors_hospitals" FOREIGN KEY ("doctor_id") REFERENCES "doctors" ("id"),
  CONSTRAINT "fk_hospital_id_doctors_hospitals" FOREIGN KEY ("hospital_id") REFERENCES "hospitals" ("id"),
  CONSTRAINT "fk_post_id_doctors_hospitals" FOREIGN KEY ("post_id") REFERENCES "doctor_posts" ("id")
);

CREATE TABLE "stuff_clinics" (
  "id" SERIAL PRIMARY KEY,
  "stuff_id" int NOT NULL,
  "clinic_id" int NOT NULL,
  "agreement" text,
  "from" date NOT NULL,
  "to" date,
  "salary" decimal NOT NULL,
  "working_rate" float NOT NULL DEFAULT 1,
  "payment_ratio" float NOT NULL DEFAULT 1,
  "vacation_days" int NOT NULL DEFAULT 28,
  CONSTRAINT "fk_stuff_id_stuff_clinics" FOREIGN KEY ("stuff_id") REFERENCES "service_staff" ("id"),
  CONSTRAINT "fk_clinic_id_stuff_clinics" FOREIGN KEY ("clinic_id") REFERENCES "polyclinics" ("id")
);

CREATE TABLE "stuff_hospitals" (
  "id" SERIAL PRIMARY KEY,
  "stuff_id" int NOT NULL,
  "hospital_id" int NOT NULL,
  "agreement" text,
  "from" date NOT NULL,
  "to" date,
  "salary" decimal NOT NULL,
  "working_rate" float NOT NULL DEFAULT 1,
  "payment_ratio" float NOT NULL DEFAULT 1,
  "vacation_days" int NOT NULL DEFAULT 28,
  CONSTRAINT "fk_stuff_id_stuff_hospitals" FOREIGN KEY ("stuff_id") REFERENCES "service_staff" ("id"),
  CONSTRAINT "fk_hospital_id_stuff_hospitals" FOREIGN KEY ("hospital_id") REFERENCES "hospitals" ("id")
);

CREATE TABLE "patients" (
  "id" SERIAL PRIMARY KEY,
  "name" text NOT NULL,
  "last_name" text NOT NULL,
  "patronymic" text,
  "gender" text NOT NULL,
  "birth_date" date NOT NULL,
  "phone_number" text,
  "citizenship" text,
  "city" text NOT NULL,
  "address" text,
  "blood_type" text NOT NULL,
  "allergies" text, --[]text
  "chronic_diseases" text, --[]text
  "clinic_id" int NOT NULL,
  CONSTRAINT "fk_clinic_id_patients" FOREIGN KEY ("clinic_id") REFERENCES "polyclinics" ("id")
);

CREATE TABLE "doctors_patients_clinic" (
  "patient_id" int NOT NULL,
  "doctor_id" int NOT NULL,
  "clinic_id" int NOT NULL,
  CONSTRAINT "pk_patient_doctor_clinic_id_doctors_patients_clinic" PRIMARY KEY ("patient_id", "doctor_id", "clinic_id"),
  CONSTRAINT "fk_patient_id_doctors_patients_clinic" FOREIGN KEY ("patient_id") REFERENCES "patients" ("id"),
  CONSTRAINT "fk_doctor_id_doctors_patients_clinic" FOREIGN KEY ("doctor_id") REFERENCES "doctors" ("id"),
  CONSTRAINT "fk_clinic_id_doctors_patients_clinic" FOREIGN KEY ("clinic_id") REFERENCES "polyclinics" ("id")
);

CREATE TABLE "drugs" (
  "id" SERIAL PRIMARY KEY,
  "name" text UNIQUE NOT NULL,
  "description" text,
  "code" text
);

CREATE TABLE "diagnoses" (
  "id" SERIAL PRIMARY KEY,
  "name" text UNIQUE NOT NULL,
  "description" text,
  "code" text
);

CREATE TABLE "outpatient_treatments" (
  "id" SERIAL PRIMARY KEY,
  "patient_id" int NOT NULL,
  "doctor_id" int NOT NULL,
  "clinic_id" int NOT NULL,
  "from" date NOT NULL,
  "to" date,
  CONSTRAINT "fk_patient_id_outpatient_treatments" FOREIGN KEY ("patient_id") REFERENCES "patients" ("id"),
  CONSTRAINT "fk_doctor_id_outpatient_treatments" FOREIGN KEY ("doctor_id") REFERENCES "doctors" ("id"),
  CONSTRAINT "fk_clinic_id_outpatient_treatments" FOREIGN KEY ("clinic_id") REFERENCES "polyclinics" ("id")
);

CREATE TABLE "outpatient_visits" (
  "id" SERIAL PRIMARY KEY,
  "treatment_id" int NOT NULL,
  "room_id" int NOT NULL,
  CONSTRAINT "fk_treatment_id_outpatient_visits" FOREIGN KEY ("treatment_id") REFERENCES "outpatient_treatments" ("id"),
  CONSTRAINT "fk_room_id_outpatient_visits" FOREIGN KEY ("room_id") REFERENCES "clinic_rooms" ("id")
);

CREATE TABLE "prescribed_diagnoses" (
  "id" SERIAL PRIMARY KEY,
  "visit_id" int NOT NULL,
  "diagnosis_id" int NOT NULL,
  "comment" text,
  CONSTRAINT "fk_visit_id_prescribed_diagnoses" FOREIGN KEY ("visit_id") REFERENCES "outpatient_visits" ("id"),
  CONSTRAINT "fk_diagnosis_id_prescribed_diagnoses" FOREIGN KEY ("diagnosis_id") REFERENCES "diagnoses" ("id")
);

CREATE TABLE "prescribed_drugs" (
  "id" SERIAL PRIMARY KEY,
  "visit_id" int NOT NULL,
  "drug_id" int NOT NULL,
  "dosage" text NOT NULL,
  CONSTRAINT "fk_visit_id_prescribed_drugs" FOREIGN KEY ("visit_id") REFERENCES "outpatient_visits" ("id"),
  CONSTRAINT "fk_drug_id_prescribed_drugs" FOREIGN KEY ("drug_id") REFERENCES "drugs" ("id")
);

CREATE TABLE "prescribed_recommendations" (
  "id" SERIAL PRIMARY KEY,
  "visit_id" int NOT NULL,
  "recommendation" text NOT NULL,
  CONSTRAINT "fk_visit_id_prescribed_recommendations" FOREIGN KEY ("visit_id") REFERENCES "outpatient_visits" ("id")
);

CREATE TABLE "out_observations" (
  "id" SERIAL PRIMARY KEY,
  "visit_id" int NOT NULL,
  "state" text NOT NULL,
  "temp_celsius" float,
  "arterial_pressure" text,
  "pulse_per_min" int,
  CONSTRAINT "fk_visit_id_out_observations" FOREIGN KEY ("visit_id") REFERENCES "outpatient_visits" ("id")
);

CREATE TABLE "referrals" (
  "id" SERIAL PRIMARY KEY,
  "visit_id" int NOT NULL,
  "hospital_id" int NOT NULL,
  "from" date NOT NULL,
  "to" date,
  "refferal_content" text NOT NULL,
  CONSTRAINT "fk_visit_id_referrals" FOREIGN KEY ("visit_id") REFERENCES "outpatient_visits" ("id"),
  CONSTRAINT "fk_hospital_id_referrals" FOREIGN KEY ("hospital_id") REFERENCES "hospitals" ("id")
);

CREATE TABLE "out_operations" (
  "id" SERIAL PRIMARY KEY,
  "treatment_id" int NOT NULL,
  "head_doctor_id" int NOT NULL,
  "description" text,
  "result" text,
  "start_planned" timestamp NOT NULL,
  "started" timestamp,
  "finish_planned" timestamp,
  "finished" timestamp,
  CONSTRAINT "fk_treatment_id_out_operations" FOREIGN KEY ("treatment_id") REFERENCES "outpatient_treatments" ("id"),
  CONSTRAINT "fk_head_doctor_id_out_operations" FOREIGN KEY ("head_doctor_id") REFERENCES "doctors" ("id")
);

CREATE TABLE "out_operations_doctors" (
  "operation_id" int NOT NULL,
  "doctor_id" int NOT NULL,
  CONSTRAINT "pk_operation_doctor_id_out_operations_doctors" PRIMARY KEY ("operation_id", "doctor_id"),
  CONSTRAINT "fk_operation_id_out_operations_doctors" FOREIGN KEY ("operation_id") REFERENCES "out_operations" ("id"),
  CONSTRAINT "fk_doctor_id_out_operations_doctors" FOREIGN KEY ("doctor_id") REFERENCES "doctors" ("id")
);

CREATE TABLE "out_operations_stuff" (
  "operation_id" int NOT NULL,
  "stuff" int NOT NULL,
  CONSTRAINT "pk_operation_id_stuff_out_operations_stuff" PRIMARY KEY ("operation_id", "stuff"),
  CONSTRAINT "fk_operation_id_out_operations_stuff" FOREIGN KEY ("operation_id") REFERENCES "out_operations" ("id"),
  CONSTRAINT "fk_stuff_out_operations_stuff" FOREIGN KEY ("stuff") REFERENCES "service_staff" ("id")
);

CREATE TABLE "inpatient_treatments" (
  "id" SERIAL PRIMARY KEY,
  "ref_id" int NOT NULL,
  "doctor_id" int NOT NULL,
  "clinic_id" int NOT NULL,
  "from" date NOT NULL,
  "to" date,
  CONSTRAINT "fk_ref_id_inpatient_treatments" FOREIGN KEY ("ref_id") REFERENCES "referrals" ("id"),
  CONSTRAINT "fk_doctor_id_inpatient_treatments" FOREIGN KEY ("doctor_id") REFERENCES "doctors" ("id"),
  CONSTRAINT "fk_clinic_id_inpatient_treatments" FOREIGN KEY ("clinic_id") REFERENCES "polyclinics" ("id")
);

CREATE TABLE "in_prescribed_drugs" (
  "id" SERIAL PRIMARY KEY,
  "treatment_id" int NOT NULL,
  "drug_id" int NOT NULL,
  "dosage" text NOT NULL,
  CONSTRAINT "fk_treatment_id_in_prescribed_drugs" FOREIGN KEY ("treatment_id") REFERENCES "inpatient_treatments" ("id"),
  CONSTRAINT "fk_drug_id_in_prescribed_drugs" FOREIGN KEY ("drug_id") REFERENCES "drugs" ("id")
);

CREATE TABLE "in_procedures" (
  "id" SERIAL PRIMARY KEY,
  "treatment_id" int NOT NULL,
  "procedure" text NOT NULL,
  CONSTRAINT "fk_treatment_id_in_procedures" FOREIGN KEY ("treatment_id") REFERENCES "inpatient_treatments" ("id")
);

CREATE TABLE "in_observations" (
  "id" SERIAL PRIMARY KEY,
  "treatment_id" int NOT NULL,
  "state" text NOT NULL,
  "temp_celsius" float,
  "arterial_pressure" text,
  "pulse_per_min" int,
  "other" json,
  CONSTRAINT "fk_treatment_id_in_observations" FOREIGN KEY ("treatment_id") REFERENCES "inpatient_treatments" ("id")
);

CREATE TABLE "in_operations" (
  "id" SERIAL PRIMARY KEY,
  "treatment_id" int NOT NULL,
  "head_doctor_id" int NOT NULL,
  "description" text,
  "result" text,
  "start_planned" timestamp NOT NULL,
  "started" timestamp,
  "finish_planned" timestamp,
  "finished" timestamp,
  CONSTRAINT "fk_treatment_id_in_operations" FOREIGN KEY ("treatment_id") REFERENCES "inpatient_treatments" ("id"),
  CONSTRAINT "fk_head_doctor_id_in_operations" FOREIGN KEY ("head_doctor_id") REFERENCES "doctors" ("id")
);

CREATE TABLE "in_operations_doctors" (
  "operation_id" int NOT NULL,
  "doctor_id" int NOT NULL,
  CONSTRAINT "pk_operation_doctor_id_in_operations_doctors" PRIMARY KEY ("operation_id", "doctor_id"),
  CONSTRAINT "fk_operation_id_in_operations_doctors" FOREIGN KEY ("operation_id") REFERENCES "in_operations" ("id"),
  CONSTRAINT "fk_doctor_id_in_operations_doctors" FOREIGN KEY ("doctor_id") REFERENCES "doctors" ("id")
);

CREATE TABLE "in_operations_stuff" (
  "operation_id" int NOT NULL,
  "stuff" int NOT NULL,
  CONSTRAINT "pk_operation_id_stuff_in_operations_stuff" PRIMARY KEY ("operation_id", "stuff"),
  CONSTRAINT "fk_operation_id_in_operations_stuff" FOREIGN KEY ("operation_id") REFERENCES "in_operations" ("id"),
  CONSTRAINT "fk_stuff_in_operations_stuff" FOREIGN KEY ("stuff") REFERENCES "service_staff" ("id")
);