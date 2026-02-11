-- 08_fisi9t_chemcoag_hourly.sql
-- Materialized view: example hourly chemistry + coagulation features.
-- This is based on the query you shared; naming it `fisi9t_chemcoag_hourly`
-- matches the API autodetection for labs hourly sources.

CREATE MATERIALIZED VIEW fisi9t_chemcoag_hourly AS (
  WITH stay_window AS (
    SELECT
      c.subject_id,
      c.stay_id,
      date_trunc('hour', id.icu_intime) AS start_hour,
      date_trunc('hour', id.icu_outtime) AS end_hour,
      id.icu_intime,
      id.icu_outtime
    FROM fisi9t_unique_patient_profile c
    JOIN icustay_detail id
      ON id.stay_id = c.stay_id
  ),
  hour_grid AS (
    SELECT
      sw.subject_id,
      sw.stay_id,
      gs AS hour_ts
    FROM stay_window sw
    CROSS JOIN LATERAL generate_series(
      sw.start_hour,
      sw.end_hour + interval '1 hour',
      interval '1 hour'
    ) gs
  ),
  chem_in_icu AS (
    SELECT
      ch.subject_id,
      c.stay_id,
      ch.charttime,
      date_trunc('hour', ch.charttime + interval '30 minutes') AS charttime_hour,
      ch.bicarbonate,
      ch.calcium,
      ch.sodium,
      ch.potassium
    FROM chemistry ch
    JOIN fisi9t_unique_patient_profile c
      ON c.subject_id = ch.subject_id
    JOIN stay_window sw
      ON sw.subject_id = c.subject_id
     AND sw.stay_id = c.stay_id
    WHERE ch.charttime >= sw.icu_intime
      AND ch.charttime <= sw.icu_outtime
  ),
  coag_in_icu AS (
    SELECT
      co.subject_id,
      c.stay_id,
      co.charttime,
      date_trunc('hour', co.charttime + interval '30 minutes') AS charttime_hour,
      co.d_dimer,
      co.fibrinogen,
      co.thrombin,
      co.inr,
      co.pt,
      co.ptt
    FROM coagulation co
    JOIN fisi9t_unique_patient_profile c
      ON c.subject_id = co.subject_id
    JOIN stay_window sw
      ON sw.subject_id = c.subject_id
     AND sw.stay_id = c.stay_id
    WHERE co.charttime >= sw.icu_intime
      AND co.charttime <= sw.icu_outtime
  ),
  chem_hourly AS (
    SELECT
      subject_id,
      stay_id,
      charttime_hour,
      min(bicarbonate) FILTER (WHERE bicarbonate IS NOT NULL) AS bicarbonate,
      avg(calcium) FILTER (WHERE calcium IS NOT NULL) AS calcium,
      avg(sodium) FILTER (WHERE sodium IS NOT NULL) AS sodium,
      max(potassium) FILTER (WHERE potassium IS NOT NULL) AS potassium
    FROM chem_in_icu
    GROUP BY subject_id, stay_id, charttime_hour
  ),
  coag_hourly AS (
    SELECT
      subject_id,
      stay_id,
      charttime_hour,
      (array_agg(inr ORDER BY charttime DESC) FILTER (WHERE inr IS NOT NULL))[1] AS inr,
      (array_agg(pt ORDER BY charttime DESC) FILTER (WHERE pt IS NOT NULL))[1] AS pt,
      (array_agg(ptt ORDER BY charttime DESC) FILTER (WHERE ptt IS NOT NULL))[1] AS ptt,
      (array_agg(thrombin ORDER BY charttime DESC) FILTER (WHERE thrombin IS NOT NULL))[1] AS thrombin,
      max(d_dimer) FILTER (WHERE d_dimer IS NOT NULL) AS d_dimer,
      min(fibrinogen) FILTER (WHERE fibrinogen IS NOT NULL) AS fibrinogen
    FROM coag_in_icu
    GROUP BY subject_id, stay_id, charttime_hour
  )
  SELECT
    g.subject_id,
    g.stay_id,
    g.hour_ts AS charttime_hour,
    ch.bicarbonate,
    ch.calcium,
    ch.sodium,
    ch.potassium,
    co.d_dimer,
    co.fibrinogen,
    co.thrombin,
    co.inr,
    co.pt,
    co.ptt
  FROM hour_grid g
  LEFT JOIN chem_hourly ch
    ON ch.stay_id = g.stay_id
   AND ch.charttime_hour = g.hour_ts
  LEFT JOIN coag_hourly co
    ON co.stay_id = g.stay_id
   AND co.charttime_hour = g.hour_ts
  ORDER BY g.stay_id, g.hour_ts
);
