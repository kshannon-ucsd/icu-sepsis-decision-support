-- 03_fis_icd9_titled.sql
-- Materialized view: ICD9 diagnoses joined to titles.

CREATE MATERIALIZED VIEW fis_icd9_titled AS (
  SELECT
    f.subject_id,
    f.hadm_id,
    f.stay_id,
    f.first_careunit,
    f.last_careunit,
    f.intime,
    f.outtime,
    f.los,
    f.seq_num,
    f.icd_code,
    f.icd_version,
    d.long_title
  FROM fis_icd9 f
  JOIN d_icd_diagnoses d
    ON f.icd_code = d.icd_code
   AND f.icd_version = d.icd_version
);
