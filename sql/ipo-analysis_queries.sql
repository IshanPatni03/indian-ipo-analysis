#1. Average listing day return by year:
SELECT 
    year,
    COUNT(*) AS ipo_count,
    ROUND(AVG(listing_return_pct), 2) AS avg_listing_return,
    ROUND(MIN(listing_return_pct), 2) AS worst,
    ROUND(MAX(listing_return_pct), 2) AS best
FROM raw_data
GROUP BY year
ORDER BY year;

#2. %age of IPOs which had a positive listing day return:
SELECT
    year,
    COUNT(*) AS total,
    SUM(CASE WHEN listing_return_pct > 0 THEN 1 ELSE 0 END) AS positive,
    ROUND(SUM(CASE WHEN listing_return_pct > 0 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 1) AS pct_positive
FROM raw_data
GROUP BY year
ORDER BY year;

#3. Top 10 best listing day performers:
SELECT full_company_name, year, issue_price, listing_return_pct
FROM raw_data
ORDER BY listing_return_pct DESC
LIMIT 10;

#4. Top 10 worst listing day performers:
SELECT full_company_name, year, issue_price, listing_return_pct
FROM raw_data
ORDER BY listing_return_pct ASC
LIMIT 10;

#5. Overall current price(prices as on 4th June 2026 performance (from price_data):
SELECT
    year,
    COUNT(*) AS ipo_count,
    ROUND(AVG(profit_loss_pct), 2) AS avg_return_from_issue,
    SUM(CASE WHEN profit_loss_pct > 0 THEN 1 ELSE 0 END) AS still_above_issue,
    ROUND(SUM(CASE WHEN profit_loss_pct > 0 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 1) AS pct_above_issue
FROM price_data
GROUP BY year
ORDER BY year;

#6. listing day returns vs current returns:
SELECT
    r.full_company_name,
    r.year,
    r.issue_price,
    r.listing_return_pct AS listing_day_return,
    p.profit_loss_pct AS current_return,
    ROUND(p.profit_loss_pct - r.listing_return_pct, 2) AS post_listing_drift
FROM raw_data r
JOIN price_data p
    ON r.listing_date = p.listing_date AND r.issue_price = p.issue_price
ORDER BY post_listing_drift ASC
LIMIT 10;

#7. Best long-term winners (high current return, moderate listing day):
SELECT
    r.full_company_name,
    r.year,
    r.listing_return_pct AS listing_day_return,
    p.profit_loss_pct AS current_return
FROM raw_data r
JOIN price_data p
    ON r.listing_date = p.listing_date AND r.issue_price = p.issue_price
WHERE r.listing_return_pct < 30
ORDER BY p.profit_loss_pct DESC
LIMIT 10;

#8. listing day winners vs long term compounders:
SELECT
    full_company_name, r.year,
    r.listing_return_pct AS listing_day,
    p.profit_loss_pct AS current_return,
    CASE
        WHEN r.listing_return_pct >= 30 AND p.profit_loss_pct >= 100 THEN 'Both strong'
        WHEN r.listing_return_pct >= 30 AND p.profit_loss_pct < 30  THEN 'Listing hero, long-term flop'
        WHEN r.listing_return_pct < 30  AND p.profit_loss_pct >= 100 THEN 'Quiet listing, long-term compounder'
        ELSE 'Average'
    END AS ipo_category
FROM raw_data r
JOIN price_data p
    ON r.listing_date = p.listing_date AND r.issue_price = p.issue_price
ORDER BY ipo_category, p.profit_loss_pct DESC;

#9. Summary count of each category:
SELECT
    CASE
        WHEN r.listing_return_pct >= 30 AND p.profit_loss_pct >= 100 THEN 'Both strong'
        WHEN r.listing_return_pct >= 30 AND p.profit_loss_pct < 30  THEN 'Listing hero, long-term flop'
        WHEN r.listing_return_pct < 30  AND p.profit_loss_pct >= 100 THEN 'Quiet listing, long-term compounder'
        ELSE 'Average'
    END AS ipo_category,
    COUNT(*) AS count,
    ROUND(AVG(p.profit_loss_pct), 2) AS avg_current_return
FROM raw_data r
JOIN price_data p
    ON r.listing_date = p.listing_date AND r.issue_price = p.issue_price
GROUP BY ipo_category
ORDER BY avg_current_return DESC;

#10. Year-wise average listing day returns vs average current returns:
SELECT
    r.year,
    COUNT(*) AS ipo_count,
    ROUND(AVG(r.listing_return_pct), 2) AS avg_listing_return,
    ROUND(AVG(p.profit_loss_pct), 2) AS avg_current_return,
    ROUND(AVG(p.profit_loss_pct) - AVG(r.listing_return_pct), 2) AS avg_drift
FROM raw_data r
JOIN price_data p
    ON r.listing_date = p.listing_date AND r.issue_price = p.issue_price
GROUP BY r.year
ORDER BY r.year;
