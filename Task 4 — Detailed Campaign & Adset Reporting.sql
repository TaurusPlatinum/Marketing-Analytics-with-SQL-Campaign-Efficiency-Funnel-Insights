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
)
SELECT
    ad_date,
    media_source,
    campaign_name,
    adset_name,
    SUM(spend) AS total_spend,
    SUM(impressions) AS total_impressions,
    SUM(clicks) AS total_clicks,
    SUM(value) AS total_value
FROM (
    SELECT * FROM facebook_data
    UNION ALL
    SELECT * FROM google_data
) AS unified_data
GROUP BY
    ad_date,
    media_source,
    campaign_name,
    adset_name
ORDER BY
    ad_date,
    media_source,
    campaign_name,
    adset_name;
