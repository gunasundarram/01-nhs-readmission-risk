-- ============================================================
-- Query 6: Data checks that qualify the headline findings
-- Period: 2024/25 unless stated | Method: Snapshot | All Ages | All Persons
-- Author: Gunasundar Ram
--
-- Why this file exists
--   Queries 1 to 5 reproduce the dashboard. These checks test how far
--   the headlines can be trusted. Run each query separately
--   (highlight it, press F5).
-- ============================================================

-- ------------------------------------------------------------
-- 6A. NHS trusts only, minimum volume, with the crude rate beside the
--     published rate.
--     * Trust codes: 3 characters starting with R (independent-sector
--       providers such as NT244 are excluded).
--     * At least 5,000 discharges.
--     * crude_rate_pct = readmissions / discharges. It differs from the
--       published rate because the published indicator is indirectly
--       standardised (age, sex, method of admission, diagnosis/procedure),
--       so the two columns should NOT be expected to match.
-- ------------------------------------------------------------
WITH clean_data AS (
    SELECT
        level_description                                         AS provider_name,
        level                                                     AS provider_code,
        CAST(REPLACE(indicator_value, ',', '') AS NUMERIC)        AS standardised_rate,
        CAST(REPLACE(numerator, ',', '') AS NUMERIC)              AS readmissions,
        CAST(REPLACE(denominator, ',', '') AS NUMERIC)            AS discharges,
        banding
    FROM readmissions_provider
    WHERE breakdown = 'Provider'
      AND TRIM(year) = '2024/25'
      AND TRIM(age_breakdown) = 'All'
      AND TRIM(sex_breakdown) = 'Persons'
      AND TRIM(method) = 'Snapshot'
      AND indicator_value ~ '^[0-9,\.]+$'
      AND numerator ~ '^[0-9,\.]+$'
      AND denominator ~ '^[0-9,\.]+$'
)
SELECT
    RANK() OVER (ORDER BY standardised_rate DESC)        AS rank_in_group,
    provider_name,
    provider_code,
    standardised_rate,
    ROUND(100 * readmissions / discharges, 1)            AS crude_rate_pct,
    readmissions,
    discharges,
    banding
FROM clean_data
WHERE provider_code ~ '^R[A-Z0-9]{2}$'
  AND discharges >= 5000
ORDER BY standardised_rate DESC
LIMIT 20;
-- Finding: 13 NHS trusts with 5,000+ discharges have a standardised rate of 17.0% or more.


-- ------------------------------------------------------------
-- 6B. Is the 10-year trend comparable across years?
--     Year-on-year change in discharges for the three trend trusts.
--     A large jump means the activity counted changed, so rates before
--     and after the jump should not be read as one continuous series.
-- ------------------------------------------------------------
WITH clean_data AS (
    SELECT
        level_description                                         AS provider_name,
        level                                                     AS provider_code,
        TRIM(year)                                                AS year,
        CAST(REPLACE(indicator_value, ',', '') AS NUMERIC)        AS standardised_rate,
        CAST(REPLACE(denominator, ',', '') AS NUMERIC)            AS discharges
    FROM readmissions_provider
    WHERE breakdown = 'Provider'
      AND TRIM(age_breakdown) = 'All'
      AND TRIM(sex_breakdown) = 'Persons'
      AND TRIM(method) = 'Snapshot'
      AND level IN ('RF4', 'RFS', 'RRE')
      AND indicator_value ~ '^[0-9,\.]+$'
      AND denominator ~ '^[0-9,\.]+$'
)
SELECT
    provider_code,
    year,
    standardised_rate,
    discharges,
    ROUND(100.0 * (discharges / NULLIF(LAG(discharges) OVER (PARTITION BY provider_code ORDER BY year), 0) - 1), 0)
                                                              AS discharges_change_pct
FROM clean_data
ORDER BY provider_code, year;
-- Finding: from 2022/23 to 2023/24 discharges rise about 50% at RF4, 15% at RFS and roughly
-- more than tenfold at RRE (540 to 5,765), so year-to-year comparisons across that point need care.


-- ------------------------------------------------------------
-- 6C. How many providers sit in each banding, overall and among NHS
--     trusts with 5,000+ discharges? Used to check the "A1 banding"
--     count quoted in the Excel summary.
-- ------------------------------------------------------------
WITH clean_data AS (
    SELECT
        level                                                     AS provider_code,
        CAST(REPLACE(denominator, ',', '') AS NUMERIC)            AS discharges,
        banding
    FROM readmissions_provider
    WHERE breakdown = 'Provider'
      AND TRIM(year) = '2024/25'
      AND TRIM(age_breakdown) = 'All'
      AND TRIM(sex_breakdown) = 'Persons'
      AND TRIM(method) = 'Snapshot'
      AND denominator ~ '^[0-9,\.]+$'
)
SELECT
    banding,
    COUNT(*)                                                      AS providers,
    COUNT(*) FILTER (WHERE provider_code ~ '^R[A-Z0-9]{2}$' AND discharges >= 5000)
                                                                  AS nhs_trusts_5000_plus
FROM clean_data
GROUP BY banding
ORDER BY banding;
