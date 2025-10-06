# Marketing Analytics Assessment - (Steps 1–4)

**PowerBI ->** [Media Performance Report](https://app.powerbi.com/view?r=eyJrIjoiNTZkNTFhZmYtZmYwZC00NTVjLWE3YTYtMjE5NmUxNWNhOTUyIiwidCI6IjRjODE4Zjc5LWFiODQtNDU1Mi05YjdjLTJmZTcxNWIwZDBkNSIsImMiOjR9)

## Introduction

**Objective:** Build a scalable, analytics-ready data model that unifies paid media performance from Facebook, Google, and TikTok into a single fact table for downstream visualization in Power BI. The deliverable is a set of SQL scripts that:

- Ingest standardized platform data into a unified table
- Validate and profile the data
- Compute core performance, engagement, and efficiency metrics
- Provide semantic views for platform, campaign, and temporal analysis

**Technological Stack:**
- Visual Studio Code (Github Codespace)
- BigQuery
- PowerBI
- Claude Sonnet 4.5

---

### Step 1 — Data Standardization and Unification (Create fact table)

#### Plan:

- Standardize column names and types across cleaned platform tables
- Union platform datasets into a single base
- Compute metrics and add time and semantic dimensions

**What we did and found:**

- Created the unified fact table fact_ads_performance using a single CREATE OR REPLACE TABLE query with CTEs:
    - facebook_unified: mapped ad_set_id → adgroup_id; spend → cost; included engagement_rate, reach, frequency
    - google_unified: mapped ad_group_id → adgroup_id; ctr → platform_engagement_rate; included quality_score, search_impression_share, conversion_value
      
     -tiktok_unified: included granular video watch milestones and social interactions (likes, shares, comments)
- Unioned all platforms and computed:
    - Core metrics: ctr, cpc, cpm, cvr, cpa, roas
    - Video metrics: completion rate, watch rates (25/50/75/100), weighted video engagement score, cpv
    - Social metrics: total_social_engagement, social_engagement_rate, virality_score, cost_per_engagement, engagement_to_conversion_rate
    - Time dimensions: year, month, quarter, week, day_of_week, day_name, month_name
    - Semantic dimensions: campaign_type (keyword-based), performance_tier (cvr thresholds)
---

### Step 2 — Validation and Profiling

**Plan:**

- Confirm row counts, distinctness of keys, platform distribution, and totals by platform to ensure data integrity pre and post-union 

**What we did and found:**

- Validated:
    - Total rows and distinct dates/campaigns to catch duplicates or gaps
    - Platform distribution of spend, impressions, clicks, conversions to confirm parity with input sources

**Outcome:**

- The unified table is consistent and complete; platform aggregation aligns with expectations from the source files.

## Step 3 — Analytic Views for BI (Platform, Campaign, Trends, Top Performers)

**Plan:**

- Create curated views for Power BI that abstract complexity and present consistent, query-efficient layer:
    - Platform-level performance
    - Campaign-level performance with semantic classification and performance tiers
    - Daily trends by platform
    - Top performers by conversions, ROAS, and cost efficiency
    - Campaign type rollups
    - Video and social engagement performance
    - A master view with all commonly used fields and metrics

**What we did and found:**

- Views created:
    - vw_platform_performance: volume totals + average efficiency metrics + conversions_per_dollar, clicks_per_dollar
    - vw_campaign_performance: campaign timelines, totals, averages, performance_tier
    - vw_daily_trends: daily platform totals + daily efficiency
    - vw_top_campaigns_by_conversions: top 10 by total conversions with CPA/CVR
    - vw_top_campaigns_by_roas: top 10 by ROAS where conversion_value is present
    - vw_top_campaigns_by_efficiency: top 10 by conversions per dollar
    - vw_campaign_type_performance: “Brand / Awareness / Conversion / Traffic / Retargeting / Shopping / Other”
    - vw_video_performance: TikTok/Facebook video-specific metrics, CPV, video→conversion rate
    - vw_social_engagement: TikTok social totals, engagement rate, virality
    - vw_powerbi_master: canonical star-like “flat” view for direct BI consumption

**Outcome:**

A semantic layer optimized for dashboarding, with flexible slices by platform, campaign, time, and engagement type, minimizing repeated metric logic in BI.

## Step 4 — Key Insights Query Scaffold

**Plan:**

Provide simple insight-ready SQL blocks that BI or analysts can use to surface headlines without complex modeling (e.g., total spend, total conversions, average CPA, best platform by conversions)

What we did and found:

- Created a small UNION-based “insights” query that outputs labeled rows:
    - Total Spend
    - Total Conversions
    - Average CPA
    - Best Platform by Conversions

**Outcome:**
Quick, ready-to-run SQL for executive summary cards and KPI tiles in BI.
