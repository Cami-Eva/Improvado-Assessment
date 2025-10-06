-- =====================================================
-- PHASE 2: DATA CLEANING & STANDARDIZATION
-- =====================================================
-- Purpose: Normalize all 3 platform tables into consistent schema
-- Output: 3 cleaned tables ready for unified fact table
-- =====================================================


-- =====================================================
-- 1. CLEANED FACEBOOK ADS TABLE
-- =====================================================

CREATE OR REPLACE TABLE `marketing_analytics.clean_facebook_ads` AS
SELECT
  -- Platform identifier
  'Facebook' AS platform,
  
  -- Date (standardized)
  CAST(date AS DATE) AS date,
  
  -- Campaign dimensions (standardized naming)
  campaign_id,
  TRIM(campaign_name) AS campaign_name,
  ad_set_id AS adgroup_id,  -- Rename to match other platforms
  TRIM(ad_set_name) AS adgroup_name,  -- Rename to match other platforms
  
  -- Core metrics (standardized naming)
  CAST(impressions AS INT64) AS impressions,
  CAST(clicks AS INT64) AS clicks,
  CAST(spend AS FLOAT64) AS spend,  -- Rename from 'spend' to standardized 'spend'
  CAST(conversions AS INT64) AS conversions,
  
  -- Facebook-specific metrics
  CAST(video_views AS INT64) AS video_views,
  CAST(reach AS INT64) AS reach,
  CAST(frequency AS FLOAT64) AS frequency,
  CAST(engagement_rate AS FLOAT64) AS engagement_rate,
  
  -- Placeholder for metrics not available on Facebook
  NULL AS video_watch_25,
  NULL AS video_watch_50,
  NULL AS video_watch_75,
  NULL AS video_watch_100,
  NULL AS likes,
  NULL AS shares,
  NULL AS comments,
  NULL AS conversion_value,
  NULL AS quality_score,
  NULL AS search_impression_share

FROM `marketing_analytics.stg_facebooks_ads`
WHERE date IS NOT NULL  -- Remove any rows with missing dates
  AND campaign_id IS NOT NULL;  -- Remove any rows with missing campaign IDs


-- =====================================================
-- 2. CLEANED GOOGLE ADS TABLE
-- =====================================================

CREATE OR REPLACE TABLE `marketing_analytics.clean_google_ads` AS
SELECT
  -- Platform identifier
  'Google Ads' AS platform,
  
  -- Date (standardized)
  CAST(date AS DATE) AS date,
  
  -- Campaign dimensions (standardized naming)
  campaign_id,
  TRIM(campaign_name) AS campaign_name,
  ad_group_id AS adgroup_id,  -- Rename to match other platforms
  TRIM(ad_group_name) AS adgroup_name,  -- Rename to match other platforms
  
  -- Core metrics (standardized naming)
  CAST(impressions AS INT64) AS impressions,
  CAST(clicks AS INT64) AS clicks,
  CAST(cost AS FLOAT64) AS spend,  -- Rename from 'cost' to standardized 'spend'
  CAST(conversions AS INT64) AS conversions,
  
  -- Google-specific metrics
  CAST(conversion_value AS FLOAT64) AS conversion_value,
  CAST(quality_score AS INT64) AS quality_score,
  CAST(search_impression_share AS FLOAT64) AS search_impression_share,
  CAST(ctr AS FLOAT64) AS ctr,
  CAST(avg_cpc AS FLOAT64) AS avg_cpc,
  
  -- Placeholder for metrics not available on Google Ads
  NULL AS video_views,
  NULL AS reach,
  NULL AS frequency,
  NULL AS engagement_rate,
  NULL AS video_watch_25,
  NULL AS video_watch_50,
  NULL AS video_watch_75,
  NULL AS video_watch_100,
  NULL AS likes,
  NULL AS shares,
  NULL AS comments

FROM `marketing_analytics.stg_google_ads`
WHERE date IS NOT NULL  -- Remove any rows with missing dates
  AND campaign_id IS NOT NULL;  -- Remove any rows with missing campaign IDs


-- =====================================================
-- 3. CLEANED TIKTOK ADS TABLE
-- =====================================================

CREATE OR REPLACE TABLE `marketing_analytics.clean_tiktok_ads` AS
SELECT
  -- Platform identifier
  'TikTok' AS platform,
  
  -- Date (standardized)
  CAST(date AS DATE) AS date,
  
  -- Campaign dimensions (standardized naming)
  campaign_id,
  TRIM(campaign_name) AS campaign_name,
  adgroup_id,  -- Already matches standard naming
  TRIM(adgroup_name) AS adgroup_name,  -- Already matches standard naming
  
  -- Core metrics (standardized naming)
  CAST(impressions AS INT64) AS impressions,
  CAST(clicks AS INT64) AS clicks,
  CAST(cost AS FLOAT64) AS spend,  -- Rename from 'cost' to standardized 'spend'
  CAST(conversions AS INT64) AS conversions,
  
  -- TikTok-specific metrics
  CAST(video_views AS INT64) AS video_views,
  CAST(video_watch_25 AS INT64) AS video_watch_25,
  CAST(video_watch_50 AS INT64) AS video_watch_50,
  CAST(video_watch_75 AS INT64) AS video_watch_75,
  CAST(video_watch_100 AS INT64) AS video_watch_100,
  CAST(likes AS INT64) AS likes,
  CAST(shares AS INT64) AS shares,
  CAST(comments AS INT64) AS comments,
  
  -- Placeholder for metrics not available on TikTok
  NULL AS reach,
  NULL AS frequency,
  NULL AS engagement_rate,
  NULL AS conversion_value,
  NULL AS quality_score,
  NULL AS search_impression_share,
  NULL AS ctr,
  NULL AS avg_cpc

FROM `marketing_analytics.stg_tiktok_ads`
WHERE date IS NOT NULL  -- Remove any rows with missing dates
  AND campaign_id IS NOT NULL;  -- Remove any rows with missing campaign IDs


-- =====================================================
-- VALIDATION: VERIFY CLEANED TABLES
-- =====================================================

-- Check row counts after cleaning
SELECT 
  'Facebook' AS platform,
  COUNT(*) AS cleaned_rows,
  COUNT(DISTINCT campaign_id) AS unique_campaigns,
  COUNT(DISTINCT adgroup_id) AS unique_adgroups,
  MIN(date) AS earliest_date,
  MAX(date) AS latest_date
FROM `marketing_analytics.clean_facebook_ads`

UNION ALL

SELECT 
  'Google Ads' AS platform,
  COUNT(*) AS cleaned_rows,
  COUNT(DISTINCT campaign_id) AS unique_campaigns,
  COUNT(DISTINCT adgroup_id) AS unique_adgroups,
  MIN(date) AS earliest_date,
  MAX(date) AS latest_date
FROM `marketing_analytics.clean_google_ads`

UNION ALL

SELECT 
  'TikTok' AS platform,
  COUNT(*) AS cleaned_rows,
  COUNT(DISTINCT campaign_id) AS unique_campaigns,
  COUNT(DISTINCT adgroup_id) AS unique_adgroups,
  MIN(date) AS earliest_date,
  MAX(date) AS latest_date
FROM `marketing_analytics.clean_tiktok_ads`;


-- =====================================================
-- Verify standardized column names match across tables
-- =====================================================

-- Facebook columns
SELECT 'Facebook' AS platform, column_name, data_type
FROM `marketing_analytics.INFORMATION_SCHEMA.COLUMNS`
WHERE table_name = 'clean_facebook_ads'
ORDER BY ordinal_position;

-- Google Ads columns
SELECT 'Google Ads' AS platform, column_name, data_type
FROM `marketing_analytics.INFORMATION_SCHEMA.COLUMNS`
WHERE table_name = 'clean_google_ads'
ORDER BY ordinal_position;

-- TikTok columns
SELECT 'TikTok' AS platform, column_name, data_type
FROM `marketing_analytics.INFORMATION_SCHEMA.COLUMNS`
WHERE table_name = 'clean_tiktok_ads'
ORDER BY ordinal_position;


-- =====================================================
-- Check for data quality issues in cleaned tables
-- =====================================================

-- Verify no negative values in key metrics
SELECT 
  'Facebook' AS platform,
  COUNTIF(impressions < 0) AS negative_impressions,
  COUNTIF(clicks < 0) AS negative_clicks,
  COUNTIF(spend < 0) AS negative_spend,
  COUNTIF(conversions < 0) AS negative_conversions
FROM `marketing_analytics.clean_facebook_ads`

UNION ALL

SELECT 
  'Google Ads' AS platform,
  COUNTIF(impressions < 0) AS negative_impressions,
  COUNTIF(clicks < 0) AS negative_clicks,
  COUNTIF(spend < 0) AS negative_spend,
  COUNTIF(conversions < 0) AS negative_conversions
FROM `marketing_analytics.clean_google_ads`

UNION ALL

SELECT 
  'TikTok' AS platform,
  COUNTIF(impressions < 0) AS negative_impressions,
  COUNTIF(clicks < 0) AS negative_clicks,
  COUNTIF(spend < 0) AS negative_spend,
  COUNTIF(conversions < 0) AS negative_conversions
FROM `marketing_analytics.clean_tiktok_ads`;


-- =====================================================
-- Preview cleaned data (first 3 rows per platform)
-- =====================================================

SELECT * FROM `marketing_analytics.clean_facebook_ads` LIMIT 3;
SELECT * FROM `marketing_analytics.clean_google_ads` LIMIT 3;
SELECT * FROM `marketing_analytics.clean_tiktok_ads` LIMIT 3;


-- =====================================================
-- Summary statistics for core metrics
-- =====================================================

SELECT 
  platform,
  SUM(impressions) AS total_impressions,
  SUM(clicks) AS total_clicks,
  SUM(spend) AS total_spend,
  SUM(conversions) AS total_conversions,
  ROUND(SUM(clicks) / NULLIF(SUM(impressions), 0) * 100, 2) AS overall_ctr,
  ROUND(SUM(spend) / NULLIF(SUM(clicks), 0), 2) AS overall_cpc,
  ROUND(SUM(spend) / NULLIF(SUM(conversions), 0), 2) AS overall_cpa
FROM (
  SELECT platform, impressions, clicks, spend, conversions
  FROM `marketing_analytics.clean_facebook_ads`
  
  UNION ALL
  
  SELECT platform, impressions, clicks, spend, conversions
  FROM `marketing_analytics.clean_google_ads`
  
  UNION ALL
  
  SELECT platform, impressions, clicks, spend, conversions
  FROM `marketing_analytics.clean_tiktok_ads`
)
GROUP BY platform
ORDER BY total_spend DESC;