-- =====================================================
-- DATA INGESTION VALIDATION SCRIPT
-- =====================================================

-- 1. ROW COUNT CHECK
-- Verify all tables loaded successfully
SELECT 
  'Facebook Ads' AS platform,
  COUNT(*) AS total_rows
FROM `improvado-assessment.marketing_analytics.stg_facebooks_ads`

UNION ALL

SELECT 
  'Google Ads' AS platform,
  COUNT(*) AS total_rows
FROM `improvado-assessment.marketing_analytics.stg_google_ads`

UNION ALL

SELECT 
  'TikTok Ads' AS platform,
  COUNT(*) AS total_rows
FROM `improvado-assessment.marketing_analytics.stg_tiktok_ads`;


-- =====================================================
-- 2. DATE RANGE CHECK
-- Ensure dates are valid and within expected range
-- =====================================================

SELECT 
  'Facebook Ads' AS platform,
  MIN(date) AS earliest_date,
  MAX(date) AS latest_date,
  COUNT(DISTINCT date) AS unique_dates
FROM `improvado-assessment.marketing_analytics.stg_facebooks_ads`

UNION ALL

SELECT 
  'Google Ads' AS platform,
  MIN(date) AS earliest_date,
  MAX(date) AS latest_date,
  COUNT(DISTINCT date) AS unique_dates
FROM `improvado-assessment.marketing_analytics.stg_google_ads`

UNION ALL

SELECT 
  'TikTok Ads' AS platform,
  MIN(date) AS earliest_date,
  MAX(date) AS latest_date,
  COUNT(DISTINCT date) AS unique_dates
FROM `improvado-assessment.marketing_analytics.stg_tiktok_ads`;


-- =====================================================
-- 3. NULL VALUE CHECK
-- Identify missing critical fields
-- =====================================================

-- Facebook Ads NULL Check
SELECT 
  'Facebook Ads' AS platform,
  COUNTIF(date IS NULL) AS null_dates,
  COUNTIF(campaign_id IS NULL) AS null_campaign_ids,
  COUNTIF(impressions IS NULL) AS null_impressions,
  COUNTIF(clicks IS NULL) AS null_clicks,
  COUNTIF(spend IS NULL) AS null_spend,
  COUNTIF(conversions IS NULL) AS null_conversions
FROM `improvado-assessment.marketing_analytics.stg_facebooks_ads`

UNION ALL

-- Google Ads NULL Check
SELECT 
  'Google Ads' AS platform,
  COUNTIF(date IS NULL) AS null_dates,
  COUNTIF(campaign_id IS NULL) AS null_campaign_ids,
  COUNTIF(impressions IS NULL) AS null_impressions,
  COUNTIF(clicks IS NULL) AS null_clicks,
  COUNTIF(cost IS NULL) AS null_cost,
  COUNTIF(conversions IS NULL) AS null_conversions
FROM `improvado-assessment.marketing_analytics.stg_google_ads`

UNION ALL

-- TikTok Ads NULL Check
SELECT 
  'TikTok Ads' AS platform,
  COUNTIF(date IS NULL) AS null_dates,
  COUNTIF(campaign_id IS NULL) AS null_campaign_ids,
  COUNTIF(impressions IS NULL) AS null_impressions,
  COUNTIF(clicks IS NULL) AS null_clicks,
  COUNTIF(cost IS NULL) AS null_cost,
  COUNTIF(conversions IS NULL) AS null_conversions
FROM `improvado-assessment.marketing_analytics.stg_tiktok_ads`;


-- =====================================================
-- 4. DATA TYPE & VALUE RANGE CHECK
-- Ensure numeric fields are reasonable
-- =====================================================

SELECT 
  'Facebook Ads' AS platform,
  MIN(impressions) AS min_impressions,
  MAX(impressions) AS max_impressions,
  AVG(impressions) AS avg_impressions,
  MIN(spend) AS min_spend,
  MAX(spend) AS max_spend,
  AVG(spend) AS avg_spend
FROM `improvado-assessment.marketing_analytics.stg_facebooks_ads`

UNION ALL

SELECT 
  'Google Ads' AS platform,
  MIN(impressions) AS min_impressions,
  MAX(impressions) AS max_impressions,
  AVG(impressions) AS avg_impressions,
  MIN(cost) AS min_spend,
  MAX(cost) AS max_spend,
  AVG(cost) AS avg_spend
FROM `improvado-assessment.marketing_analytics.stg_google_ads`

UNION ALL

SELECT 
  'TikTok Ads' AS platform,
  MIN(impressions) AS min_impressions,
  MAX(impressions) AS max_impressions,
  AVG(impressions) AS avg_impressions,
  MIN(cost) AS min_spend,
  MAX(cost) AS max_spend,
  AVG(cost) AS avg_spend
FROM `improvado-assessment.marketing_analytics.stg_tiktok_ads`;


-- =====================================================
-- 5. DUPLICATE CHECK
-- Identify potential duplicate records
-- =====================================================

-- Facebook Ads Duplicates
SELECT 
  'Facebook Ads' AS platform,
  date,
  campaign_id,
  ad_set_id,
  COUNT(*) AS duplicate_count
FROM `improvado-assessment.marketing_analytics.stg_facebooks_ads`
GROUP BY date, campaign_id, ad_set_id
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC
LIMIT 10;

-- Google Ads Duplicates
SELECT 
  'Google Ads' AS platform,
  date,
  campaign_id,
  ad_group_id,
  COUNT(*) AS duplicate_count
FROM `improvado-assessment.marketing_analytics.stg_google_ads`
GROUP BY date, campaign_id, ad_group_id
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC
LIMIT 10;

-- TikTok Ads Duplicates
SELECT 
  'TikTok Ads' AS platform,
  date,
  campaign_id,
  adgroup_id,
  COUNT(*) AS duplicate_count
FROM `improvado-assessment.marketing_analytics.stg_tiktok_ads`
GROUP BY date, campaign_id, adgroup_id
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC
LIMIT 10;


-- =====================================================
-- 6. SAMPLE DATA PREVIEW
-- Quick visual check of first 5 rows per platform
-- =====================================================

SELECT 'Facebook Ads' AS platform, * 
FROM `improvado-assessment.marketing_analytics.stg_facebooks_ads` 
LIMIT 5;

SELECT 'Google Ads' AS platform, * 
FROM `improvado-assessment.marketing_analytics.stg_google_ads` 
LIMIT 5;

SELECT 'TikTok Ads' AS platform, * 
FROM `improvado-assessment.marketing_analytics.stg_tiktok_ads` 
LIMIT 5;