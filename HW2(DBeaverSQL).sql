SELECT ad_date
, campaign_id
, SUM(spend) AS total_spend
, SUM(impressions) AS total_impressions
, SUM(clicks) AS total_clicks
, SUM(value) AS total_conversion_value
, ROUND(SUM(spend) / NULLIF(SUM(clicks), 0), 2) AS cpc
, ROUND(SUM(spend) / NULLIF(SUM(impressions), 0), 2) AS cpm
, ROUND(NULLIF(SUM(clicks), 0) / NULLIF(SUM(impressions), 0), 2) AS ctr
, ROUND((SUM(value) - SUM(spend))/NULLIF(SUM(spend), 0) * 100, 2) AS romi
, ROUND(SUM(spend) / NULLIF(SUM(value), 0), 2) AS cpa
FROM homeworks.facebook_ads_basic_daily
GROUP BY ad_date, campaign_id
ORDER BY ad_date, campaign_id
