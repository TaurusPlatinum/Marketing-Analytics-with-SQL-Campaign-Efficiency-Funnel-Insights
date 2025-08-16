WITH global_ads_data AS (
    SELECT
        ad_date,
        'Facebook Ads' AS media_source,
        spend,
        impressions,
        reach,
        clicks,
        leads,
        value
    FROM homeworks.facebook_ads_basic_daily

    UNION ALL

    SELECT
        ad_date,
        'Google Ads' AS media_source,
        spend,
        impressions,
        reach,
        clicks,
        leads,
        value
    FROM google_ads_basic_daily
)

SELECT 
	ad_date,
    media_source,
    SUM(spend) AS total_spend,
    SUM(impressions) AS total_impressions,
    SUM(clicks) AS total_clicks,
    SUM(value) AS total_value
FROM global_ads_data
GROUP BY ad_date, media_source
ORDER BY ad_date, media_source;
