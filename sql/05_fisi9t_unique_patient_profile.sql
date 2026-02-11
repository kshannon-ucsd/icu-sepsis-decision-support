-- 05_fisi9t_unique_patient_profile.sql
-- Materialized view: unique patient profile per subject_id.

CREATE MATERIALIZED VIEW fisi9t_unique_patient_profile AS (
  SELECT DISTINCT ON (subject_id)
    subject_id,
    anchor_age,
    gender,
    race,
    hadm_id,
    stay_id,
    first_careunit,
    last_careunit,
    intime,
    outtime,
    los
  FROM fisi9t_profile p
);
