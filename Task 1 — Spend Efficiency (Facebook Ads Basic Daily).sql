SELECT ad_date, spend, clicks, spend/clicks as ValueForClicks
FROM homeworks.facebook_ads_basic_daily
WHERE clicks IS NOT NULL AND clicks <> 0
ORDER BY ad_date DESC;
