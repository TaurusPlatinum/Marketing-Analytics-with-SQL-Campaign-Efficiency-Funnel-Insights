WITH combined_ads_data AS (
    SELECT
        ad_date,
        url_parameters,
        COALESCE(spend, 0) AS spend,
        COALESCE(impressions, 0) AS impressions,
        COALESCE(reach, 0) AS reach,
        COALESCE(clicks, 0) AS clicks,
        COALESCE(leads, 0) AS leads,
        COALESCE(value, 0) AS value
    FROM facebook_ads_basic_daily
    UNION ALL
    SELECT
        ad_date,
        url_parameters,
        COALESCE(spend, 0) AS spend,
        COALESCE(impressions, 0) AS impressions,
        COALESCE(reach, 0) AS reach,
        COALESCE(clicks, 0) AS clicks,
        COALESCE(leads, 0) AS leads,
        COALESCE(value, 0) AS value
    FROM google_ads_basic_daily
),

parsed_data AS (
    SELECT
        ad_date,
        CASE 
            WHEN LOWER(SUBSTRING(url_parameters FROM 'utm_campaign=([^&]+)')) = 'nan' THEN NULL
            ELSE LOWER(SUBSTRING(url_parameters FROM 'utm_campaign=([^&]+)'))
        END AS utm_campaign,
        spend,
        impressions,
        clicks,
        value
    FROM combined_ads_data
),

aggregated_data AS (
    SELECT
        DATE_TRUNC('month', ad_date) AS ad_month,
        utm_campaign,
        SUM(spend) AS total_spend,
        SUM(impressions) AS total_impressions,
        SUM(clicks) AS total_clicks,
        SUM(value) AS total_value,
        CASE 
            WHEN SUM(impressions) = 0 THEN 0
            ELSE ROUND((SUM(clicks)::NUMERIC * 100.0) / SUM(impressions), 2)
        END AS CTR,
        CASE 
            WHEN SUM(clicks) = 0 THEN 0
            ELSE ROUND(SUM(spend)::NUMERIC / SUM(clicks), 2)
        END AS CPC,
        CASE 
            WHEN SUM(impressions) = 0 THEN 0
            ELSE ROUND((SUM(spend)::NUMERIC * 1000.0) / SUM(impressions), 2)
        END AS CPM,
        CASE 
            WHEN SUM(spend) = 0 THEN 0
            ELSE ROUND((SUM(value) - SUM(spend)) / SUM(spend)::NUMERIC, 2)
        END AS ROMI
    FROM parsed_data
    GROUP BY DATE_TRUNC('month', ad_date), utm_campaign
),

final_with_deltas AS (
    SELECT
        *,
        ROUND(
            CASE 
                WHEN LAG(CPM) OVER (PARTITION BY utm_campaign ORDER BY ad_month) = 0 THEN NULL
                ELSE ((CPM - LAG(CPM) OVER (PARTITION BY utm_campaign ORDER BY ad_month)) 
                      / LAG(CPM) OVER (PARTITION BY utm_campaign ORDER BY ad_month)) * 100
            END, 2
        ) AS delta_CPM_percent,
        
        ROUND(
            CASE 
                WHEN LAG(CTR) OVER (PARTITION BY utm_campaign ORDER BY ad_month) = 0 THEN NULL
                ELSE ((CTR - LAG(CTR) OVER (PARTITION BY utm_campaign ORDER BY ad_month)) 
                      / LAG(CTR) OVER (PARTITION BY utm_campaign ORDER BY ad_month)) * 100
            END, 2
        ) AS delta_CTR_percent,

        ROUND(
            CASE 
                WHEN LAG(ROMI) OVER (PARTITION BY utm_campaign ORDER BY ad_month) = 0 THEN NULL
                ELSE ((ROMI - LAG(ROMI) OVER (PARTITION BY utm_campaign ORDER BY ad_month)) 
                      / LAG(ROMI) OVER (PARTITION BY utm_campaign ORDER BY ad_month)) * 100
            END, 2
        ) AS delta_ROMI_percent
    FROM aggregated_data
)

SELECT *
FROM final_with_deltas
ORDER BY ad_month, utm_campaign;
