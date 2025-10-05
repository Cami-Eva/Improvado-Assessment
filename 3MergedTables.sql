-- ============================================================================
-- STEP 1: CREATE UNIFIED FACT TABLE
-- ============================================================================

CREATE OR REPLACE TABLE `improvado-assessment.marketing_analytics.fact_ads_performance` AS
WITH 
-- Standardize Facebook data
facebook_unified AS (
  SELECT
     date,
    'Facebook' AS platform,
    campaign_id,
    campaign_name,
    NULL  AS adgroup_id,
    NULL  AS adgroup_name,
    impressions,
    clicks,
    spend AS cost,
    conversions,
    CAST(NULL AS FLOAT64) AS conversion_value,
    video_views,
    CAST(NULL AS INT64) AS video_watch_25,
    CAST(NULL AS INT64) AS video_watch_50,
    CAST(NULL AS INT64) AS video_watch_75,
    CAST(NULL AS INT64) AS video_watch_100,
    engagement_rate,
    reach,
    frequency,
    CAST(NULL AS INT64) AS likes,
    CAST(NULL AS INT64) AS shares,
    CAST(NULL AS INT64) AS comments,
    CAST(NULL AS FLOAT64) AS quality_score,
    CAST(NULL AS FLOAT64) AS search_impression_share
  FROM `improvado-assessment.marketing_analytics.clean_facebook_ads`),

-- Standardize Google data
google_unified AS (
  SELECT
     date,
    'Google' AS platform,
    campaign_id,
    campaign_name,
    NULL AS adgroup_id,
    NULL AS adgroup_name,
    impressions,
    clicks,
    spend AS cost,
    conversions,
    conversion_value,
    CAST(NULL AS INT64) AS video_views,
    CAST(NULL AS INT64) AS video_watch_25,
    CAST(NULL AS INT64) AS video_watch_50,
    CAST(NULL AS INT64) AS video_watch_75,
    CAST(NULL AS INT64) AS video_watch_100,
    ctr AS engagement_rate,
    CAST(NULL AS INT64) AS reach,
    CAST(NULL AS FLOAT64) AS frequency,
    CAST(NULL AS INT64) AS likes,
    CAST(NULL AS INT64) AS shares,
    CAST(NULL AS INT64) AS comments,
    quality_score,
    search_impression_share
  FROM `improvado-assessment.marketing_analytics.clean_google_ads`),

-- Standardize TikTok data
tiktok_unified AS (
  SELECT
     date,
    'TikTok' AS platform,
    campaign_id,
    campaign_name,
    NULL AS adgroup_id,
    NULL AS adgroup_name,
    impressions,
    clicks,
    spend AS cost,
    conversions,
    CAST(NULL AS FLOAT64) AS conversion_value,
    video_views,
    video_watch_25,
    video_watch_50,
    video_watch_75,
    video_watch_100,
    CAST(NULL AS FLOAT64) AS engagement_rate,
    CAST(NULL AS INT64) AS reach,
    CAST(NULL AS FLOAT64) AS frequency,
    likes,
    shares,
    comments,
    CAST(NULL AS FLOAT64) AS quality_score,
    CAST(NULL AS FLOAT64) AS search_impression_share
  FROM `improvado-assessment.marketing_analytics.clean_tiktok_ads`),

-- Union all platforms
unified_base AS (
  SELECT * FROM facebook_unified
  UNION ALL
  SELECT * FROM google_unified
  UNION ALL
  SELECT * FROM tiktok_unified
)

-- Add calculated metrics and dimensions
SELECT
  -- Primary Keys & Dimensions
  date,
  platform,
  campaign_id,
  campaign_name,
  adgroup_id,
  adgroup_name,
  
  -- Raw Metrics
  impressions,
  clicks,
  cost,
  conversions,
  conversion_value,
  video_views,
  video_watch_25,
  video_watch_50,
  video_watch_75,
  video_watch_100,
  engagement_rate AS platform_engagement_rate,
  reach,
  frequency,
  likes,
  shares,
  comments,
  quality_score,
  search_impression_share,
  
  -- ========================================================================
  -- CORE PERFORMANCE METRICS
  -- ========================================================================
  
  -- CTR: Click-Through Rate (%)
  ROUND(SAFE_DIVIDE(clicks, impressions) * 100, 2) AS ctr,
  
  -- CPC: Cost Per Click ($)
  ROUND(SAFE_DIVIDE(cost, clicks), 2) AS cpc,
  
  -- CPM: Cost Per Mille/1000 Impressions ($)
  ROUND(SAFE_DIVIDE(cost, impressions) * 1000, 2) AS cpm,
  
  -- CVR: Conversion Rate (%)
  ROUND(SAFE_DIVIDE(conversions, clicks) * 100, 2) AS cvr,
  
  -- CPA: Cost Per Acquisition ($)
  ROUND(SAFE_DIVIDE(cost, conversions), 2) AS cpa,
  
  -- ROAS: Return on Ad Spend (ratio)
  ROUND(SAFE_DIVIDE(conversion_value, cost), 2) AS roas,
  
  -- ========================================================================
  -- VIDEO ENGAGEMENT METRICS
  -- ========================================================================
  
  -- Video Completion Rate (%)
  ROUND(SAFE_DIVIDE(video_watch_100, video_views) * 100, 2) AS video_completion_rate,
  
  -- Video 25% Watch Rate
  ROUND(SAFE_DIVIDE(video_watch_25, video_views) * 100, 2) AS video_watch_25_rate,
  
  -- Video 50% Watch Rate
  ROUND(SAFE_DIVIDE(video_watch_50, video_views) * 100, 2) AS video_watch_50_rate,
  
  -- Video 75% Watch Rate
  ROUND(SAFE_DIVIDE(video_watch_75, video_views) * 100, 2) AS video_watch_75_rate,
  
  -- Weighted Video Engagement Score (0-100)
  ROUND(
    SAFE_DIVIDE(
      (COALESCE(video_watch_25, 0) * 0.25 + 
       COALESCE(video_watch_50, 0) * 0.50 + 
       COALESCE(video_watch_75, 0) * 0.75 + 
       COALESCE(video_watch_100, 0) * 1.0),
      video_views
    ) * 100, 2
  ) AS video_engagement_score,
  
  -- ========================================================================
  -- SOCIAL ENGAGEMENT METRICS
  -- ========================================================================
  
  -- Total Social Engagement
  (COALESCE(likes, 0) + COALESCE(shares, 0) + COALESCE(comments, 0)) AS total_social_engagement,
  
  -- Social Engagement Rate (%)
  ROUND(
    SAFE_DIVIDE(
      (COALESCE(likes, 0) + COALESCE(shares, 0) + COALESCE(comments, 0)),
      impressions
    ) * 100, 4
  ) AS social_engagement_rate,
  
  -- Virality Score (shares per impression)
  ROUND(SAFE_DIVIDE(shares, impressions) * 10000, 2) AS virality_score,
  
  -- ========================================================================
  -- EFFICIENCY METRICS
  -- ========================================================================
  
  -- Cost Per Video View
  ROUND(SAFE_DIVIDE(cost, video_views), 3) AS cpv,
  
  -- Cost Per Engagement
  ROUND(
    SAFE_DIVIDE(
      cost,
      (COALESCE(likes, 0) + COALESCE(shares, 0) + COALESCE(comments, 0))
    ), 2
  ) AS cost_per_engagement,
  
  -- Engagement to Conversion Rate (%)
  ROUND(
    SAFE_DIVIDE(
      conversions,
      (COALESCE(likes, 0) + COALESCE(shares, 0) + COALESCE(comments, 0))
    ) * 100, 2
  ) AS engagement_to_conversion_rate,
  
  -- ========================================================================
  -- TIME DIMENSIONS
  -- ========================================================================
  
  EXTRACT(YEAR FROM date) AS year,
  EXTRACT(MONTH FROM date) AS month,
  EXTRACT(QUARTER FROM date) AS quarter,
  EXTRACT(WEEK FROM date) AS week,
  EXTRACT(DAYOFWEEK FROM date) AS day_of_week,
  FORMAT_DATE('%A', date) AS day_name,
  FORMAT_DATE('%B', date) AS month_name,
  
  -- ========================================================================
  -- CAMPAIGN CLASSIFICATION
  -- ========================================================================
  
  CASE
    WHEN LOWER(campaign_name) LIKE '%brand%' THEN 'Brand'
    WHEN LOWER(campaign_name) LIKE '%awareness%' THEN 'Awareness'
    WHEN LOWER(campaign_name) LIKE '%conversion%' THEN 'Conversion'
    WHEN LOWER(campaign_name) LIKE '%traffic%' THEN 'Traffic'
    WHEN LOWER(campaign_name) LIKE '%retargeting%' THEN 'Retargeting'
    WHEN LOWER(campaign_name) LIKE '%shopping%' THEN 'Shopping'
    ELSE 'Other'
  END AS campaign_type,
  
  -- Performance Tier based on CVR
  CASE
    WHEN SAFE_DIVIDE(conversions, clicks) >= 0.05 THEN 'High Performer'
    WHEN SAFE_DIVIDE(conversions, clicks) >= 0.02 THEN 'Medium Performer'
    WHEN SAFE_DIVIDE(conversions, clicks) > 0 THEN 'Low Performer'
    ELSE 'No Conversions'
  END AS performance_tier

FROM unified_base;

-- ============================================================================
-- STEP 2: VALIDATION QUERIES
-- ============================================================================

-- Check row counts
SELECT 
  'Total Rows' AS metric,
  COUNT(*) AS value
FROM `improvado-assessment.marketing_analytics.fact_ads_performance`

UNION ALL

SELECT 
  'Unique Dates' AS metric,
  COUNT(DISTINCT date) AS value
FROM `improvado-assessment.marketing_analytics.fact_ads_performance`

UNION ALL

SELECT 
  'Unique Campaigns' AS metric,
  COUNT(DISTINCT campaign_id) AS value
FROM `improvado-assessment.marketing_analytics.fact_ads_performance`;

-- Platform distribution
SELECT
  platform,
  COUNT(*) AS row_count,
  SUM(impressions) AS total_impressions,
  SUM(clicks) AS total_clicks,
  SUM(cost) AS total_cost,
  SUM(conversions) AS total_conversions
FROM `improvado-assessment.marketing_analytics.fact_ads_performance`
GROUP BY platform
ORDER BY total_cost DESC;

-- ============================================================================
-- STEP 3: PLATFORM PERFORMANCE SUMMARY
-- ============================================================================

CREATE OR REPLACE VIEW `improvado-assessment.marketing_analytics.vw_platform_performance` AS
SELECT
  platform,
  COUNT(DISTINCT date) AS days_active,
  COUNT(DISTINCT campaign_id) AS total_campaigns,
  
  -- Volume Metrics
  SUM(impressions) AS total_impressions,
  SUM(clicks) AS total_clicks,
  SUM(conversions) AS total_conversions,
  SUM(cost) AS total_cost,
  SUM(conversion_value) AS total_conversion_value,
  
  -- Average Performance Metrics
  ROUND(AVG(ctr), 2) AS avg_ctr,
  ROUND(AVG(cpc), 2) AS avg_cpc,
  ROUND(AVG(cpm), 2) AS avg_cpm,
  ROUND(AVG(cvr), 2) AS avg_cvr,
  ROUND(AVG(cpa), 2) AS avg_cpa,
  ROUND(AVG(roas), 2) AS avg_roas,
  
  -- Video Metrics (where applicable)
  SUM(video_views) AS total_video_views,
  ROUND(AVG(video_completion_rate), 2) AS avg_video_completion_rate,
  ROUND(AVG(video_engagement_score), 2) AS avg_video_engagement_score,
  
  -- Social Metrics (where applicable)
  SUM(total_social_engagement) AS total_social_engagement,
  ROUND(AVG(social_engagement_rate), 4) AS avg_social_engagement_rate,
  
  -- Efficiency Scores
  ROUND(SAFE_DIVIDE(SUM(conversions), SUM(cost)), 2) AS conversions_per_dollar,
  ROUND(SAFE_DIVIDE(SUM(clicks), SUM(cost)), 2) AS clicks_per_dollar

FROM `improvado-assessment.marketing_analytics.fact_ads_performance`
GROUP BY platform
ORDER BY total_cost DESC;


-- ============================================================================
-- STEP 4: CAMPAIGN PERFORMANCE SUMMARY
-- ============================================================================

CREATE OR REPLACE VIEW `improvado-assessment.marketing_analytics.vw_campaign_performance` AS
SELECT
  platform,
  campaign_id,
  campaign_name,
  campaign_type,
  
  -- Date Range
  MIN(date) AS start_date,
  MAX(date) AS end_date,
  COUNT(DISTINCT date) AS days_active,
  
  -- Volume Metrics
  SUM(impressions) AS total_impressions,
  SUM(clicks) AS total_clicks,
  SUM(conversions) AS total_conversions,
  SUM(cost) AS total_cost,
  SUM(conversion_value) AS total_conversion_value,
  
  -- Performance Metrics
  ROUND(AVG(ctr), 2) AS avg_ctr,
  ROUND(AVG(cpc), 2) AS avg_cpc,
  ROUND(AVG(cvr), 2) AS avg_cvr,
  ROUND(AVG(cpa), 2) AS avg_cpa,
  ROUND(AVG(roas), 2) AS avg_roas,
  
  -- Engagement Metrics
  SUM(video_views) AS total_video_views,
  SUM(total_social_engagement) AS total_social_engagement,
  
  -- Efficiency
  ROUND(SAFE_DIVIDE(SUM(conversions), SUM(cost)), 2) AS conversions_per_dollar,
  
  -- Performance Classification
  MAX(performance_tier) AS performance_tier

FROM `improvado-assessment.marketing_analytics.fact_ads_performance`
GROUP BY platform, campaign_id, campaign_name, campaign_type
ORDER BY total_conversions DESC;


-- ============================================================================
-- STEP 5: DAILY TREND ANALYSIS
-- ============================================================================

CREATE OR REPLACE VIEW `improvado-assessment.marketing_analytics.vw_daily_trends` AS
SELECT
  date,
  day_name,
  platform,
  
  -- Daily Totals
  SUM(impressions) AS daily_impressions,
  SUM(clicks) AS daily_clicks,
  SUM(conversions) AS daily_conversions,
  SUM(cost) AS daily_cost,
  
  -- Daily Averages
  ROUND(AVG(ctr), 2) AS avg_ctr,
  ROUND(AVG(cvr), 2) AS avg_cvr,
  ROUND(AVG(cpa), 2) AS avg_cpa,
  
  -- Day Performance
  ROUND(SAFE_DIVIDE(SUM(conversions), SUM(cost)), 2) AS daily_efficiency

FROM `improvado-assessment.marketing_analytics.fact_ads_performance`
GROUP BY date, day_name, platform
ORDER BY date, platform;


-- ============================================================================
-- STEP 6: TOP PERFORMERS ANALYSIS
-- ============================================================================

-- Top 10 Campaigns by Conversions
CREATE OR REPLACE VIEW `improvado-assessment.marketing_analytics.vw_top_campaigns_by_conversions` AS
SELECT
  platform,
  campaign_name,
  SUM(conversions) AS total_conversions,
  SUM(cost) AS total_cost,
  ROUND(AVG(cpa), 2) AS avg_cpa,
  ROUND(AVG(cvr), 2) AS avg_cvr
FROM `improvado-assessment.marketing_analytics.fact_ads_performance`
GROUP BY platform, campaign_name
ORDER BY total_conversions DESC
LIMIT 10;

-- Top 10 Campaigns by ROAS
CREATE OR REPLACE VIEW `improvado-assessment.marketing_analytics.vw_top_campaigns_by_roas` AS
SELECT
  platform,
  campaign_name,
  ROUND(AVG(roas), 2) AS avg_roas,
  SUM(conversion_value) AS total_conversion_value,
  SUM(cost) AS total_cost,
  SUM(conversions) AS total_conversions
FROM `improvado-assessment.marketing_analytics.fact_ads_performance`
WHERE roas IS NOT NULL AND roas > 0
GROUP BY platform, campaign_name
ORDER BY avg_roas DESC
LIMIT 10;

-- Top 10 Campaigns by Efficiency (Conversions per Dollar)
CREATE OR REPLACE VIEW `improvado-assessment.marketing_analytics.vw_top_campaigns_by_efficiency` AS
SELECT
  platform,
  campaign_name,
  SUM(conversions) AS total_conversions,
  SUM(cost) AS total_cost,
  ROUND(SAFE_DIVIDE(SUM(conversions), SUM(cost)), 2) AS conversions_per_dollar,
  ROUND(AVG(cpa), 2) AS avg_cpa
FROM `improvado-assessment.marketing_analytics.fact_ads_performance`
GROUP BY platform, campaign_name
HAVING SUM(cost) > 0
ORDER BY conversions_per_dollar DESC
LIMIT 10;

-- ============================================================================
-- STEP 7: CAMPAIGN TYPE ANALYSIS
-- ============================================================================

CREATE OR REPLACE VIEW `improvado-assessment.marketing_analytics.vw_campaign_type_performance` AS
SELECT
  campaign_type,
  COUNT(DISTINCT campaign_id) AS total_campaigns,
  SUM(impressions) AS total_impressions,
  SUM(clicks) AS total_clicks,
  SUM(conversions) AS total_conversions,
  SUM(cost) AS total_cost,
  
  -- Performance Metrics
  ROUND(AVG(ctr), 2) AS avg_ctr,
  ROUND(AVG(cvr), 2) AS avg_cvr,
  ROUND(AVG(cpa), 2) AS avg_cpa,
  
  -- Efficiency
  ROUND(SAFE_DIVIDE(SUM(conversions), SUM(cost)), 2) AS conversions_per_dollar

FROM `improvado-assessment.marketing_analytics.fact_ads_performance`
GROUP BY campaign_type
ORDER BY total_conversions DESC;

-- ============================================================================
-- STEP 8: VIDEO PERFORMANCE ANALYSIS (TikTok & Facebook)
-- ============================================================================

CREATE OR REPLACE VIEW `improvado-assessment.marketing_analytics.vw_video_performance` AS
SELECT
  platform,
  campaign_name,
  SUM(video_views) AS total_video_views,
  SUM(video_watch_100) AS total_completions,
  ROUND(AVG(video_completion_rate), 2) AS avg_completion_rate,
  ROUND(AVG(video_engagement_score), 2) AS avg_engagement_score,
  ROUND(AVG(cpv), 3) AS avg_cpv,
  SUM(conversions) AS total_conversions,
  
  -- Video to Conversion Rate
  ROUND(SAFE_DIVIDE(SUM(conversions), SUM(video_views)) * 100, 2) AS video_to_conversion_rate

FROM `improvado-assessment.marketing_analytics.fact_ads_performance`
WHERE video_views IS NOT NULL AND video_views > 0
GROUP BY platform, campaign_name
ORDER BY total_video_views DESC;

-- ============================================================================
-- STEP 9: SOCIAL ENGAGEMENT ANALYSIS (TikTok)
-- ============================================================================

CREATE OR REPLACE VIEW `improvado-assessment.marketing_analytics.vw_social_engagement` AS
SELECT
  platform,
  campaign_name,
  SUM(likes) AS total_likes,
  SUM(shares) AS total_shares,
  SUM(comments) AS total_comments,
  SUM(total_social_engagement) AS total_engagement,
  ROUND(AVG(social_engagement_rate), 4) AS avg_engagement_rate,
  ROUND(AVG(virality_score), 2) AS avg_virality_score,
  SUM(conversions) AS total_conversions,
  
  -- Social to Conversion Rate
  ROUND(SAFE_DIVIDE(SUM(conversions), SUM(total_social_engagement)) * 100, 2) AS social_to_conversion_rate

FROM `improvado-assessment.marketing_analytics.fact_ads_performance`
WHERE total_social_engagement > 0
GROUP BY platform, campaign_name
ORDER BY total_engagement DESC;

-- ============================================================================
-- STEP 10: POWER BI MASTER VIEW
-- ============================================================================

CREATE OR REPLACE VIEW `improvado-assessment.marketing_analytics.vw_powerbi_master` AS
SELECT
  -- Dimensions
  date,
  year,
  month,
  quarter,
  week,
  day_of_week,
  day_name,
  month_name,
  platform,
  campaign_id,
  campaign_name,
  campaign_type,
  adgroup_id,
  adgroup_name,
  performance_tier,
  
  -- Raw Metrics
  impressions,
  clicks,
  cost,
  conversions,
  conversion_value,
  video_views,
  video_watch_25,
  video_watch_50,
  video_watch_75,
  video_watch_100,
  reach,
  frequency,
  likes,
  shares,
  comments,
  quality_score,
  search_impression_share,
  
  -- Core Performance Metrics
  ctr,
  cpc,
  cpm,
  cvr,
  cpa,
  roas,
  
  -- Video Metrics
  video_completion_rate,
  video_watch_25_rate,
  video_watch_50_rate,
  video_watch_75_rate,
  video_engagement_score,
  cpv,
  
  -- Social Metrics
  total_social_engagement,
  social_engagement_rate,
  virality_score,
  cost_per_engagement,
  engagement_to_conversion_rate

FROM `improvado-assessment.marketing_analytics.fact_ads_performance`;

-- ============================================================================
-- STEP 11: KEY INSIGHTS QUERY
-- ============================================================================

-- Overall Performance Summary
SELECT
  'Overall Performance' AS insight_category,
  CONCAT('Total Spend: $', ROUND(SUM(cost), 2)) AS insight_value
FROM `improvado-assessment.marketing_analytics.fact_ads_performance`

UNION ALL

SELECT
  'Overall Performance',
  CONCAT('Total Conversions: ', SUM(conversions))
FROM `improvado-assessment.marketing_analytics.fact_ads_performance`

UNION ALL

SELECT
  'Overall Performance',
  CONCAT('Average CPA: $', ROUND(AVG(cpa), 2))
FROM `improvado-assessment.marketing_analytics.fact_ads_performance`

UNION ALL

SELECT
  'Best Platform by Conversions',
  CONCAT(platform, ': ', SUM(conversions), ' conversions')
FROM `improvado-assessment.marketing_analytics.fact_ads_performance`
GROUP BY platform
LIMIT 1;