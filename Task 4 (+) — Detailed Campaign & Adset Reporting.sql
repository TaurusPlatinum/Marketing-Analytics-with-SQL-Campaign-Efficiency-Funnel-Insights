WITH facebook_data AS (
    SELECT
        fb.ad_date,
        'Facebook Ads' AS media_source,
        fc.campaign_name,
        fa.adset_name,
        fb.spend,
        fb.impressions,
        fb.reach,
        fb.clicks,
        fb.leads,
        fb.value
    FROM
        facebook_ads_basic_daily fb
    LEFT JOIN facebook_adset fa ON fb.adset_id = fa.adset_id
    LEFT JOIN facebook_campaign fc ON fb.campaign_id = fc.campaign_id
),
google_data AS (
    SELECT
        ad_date,
        'Google Ads' AS media_source,
        campaign_name,
        adset_name,
        spend,
        impressions,
        reach,
        clicks,
        leads,
        value
    FROM
        google_ads_basic_daily
),
all_ads_data AS (
    SELECT * FROM facebook_data
    UNION ALL
    SELECT * FROM google_data
),
top_campaign AS (
    SELECT 
        campaign_name, 
        SUM(spend) AS total_spend, 
        SUM(value)::numeric / NULLIF(SUM(spend), 0) AS romi
    FROM all_ads_data
    WHERE spend > 0
    GROUP BY campaign_name
    HAVING SUM(spend) >= 500000
    ORDER BY romi DESC
    LIMIT 1
)
SELECT 
    aad.adset_name,
    SUM(aad.spend) AS total_spend,
    SUM(aad.value) AS total_value,
    SUM(aad.value)::numeric / NULLIF(SUM(aad.spend), 0) AS romi
FROM all_ads_data aad
JOIN top_campaign tc ON tc.campaign_name = aad.campaign_name
WHERE aad.spend > 0
GROUP BY aad.adset_name
ORDER BY romi DESC;
