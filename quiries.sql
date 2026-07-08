SELECT c.name AS category, t.name AS top_tool, t.rating_avg
FROM tools t
JOIN categories c ON t.category_id = c.category_id
WHERE (t.category_id, t.rating_avg) IN (
    SELECT category_id, MAX(rating_avg)
    FROM tools
    GROUP BY category_id
)
ORDER BY c.name;



SELECT t.name, t.pricing_type, COUNT(r.recommendation_id) AS times_recommended, AVG(r.score) AS avg_score
FROM recommendations r
JOIN tools t ON r.tool_id = t.tool_id
GROUP BY t.tool_id
ORDER BY times_recommended DESC, avg_score DESC
LIMIT 10;



SELECT u.name AS user_name, uq.query_text, t.name AS recommended_tool, r.score, r.rank
FROM users u
JOIN user_queries uq ON u.user_id = uq.user_id
JOIN recommendations r ON uq.query_id = r.query_id
JOIN tools t ON r.tool_id = t.tool_id
WHERE u.user_id = 1
ORDER BY uq.created_at, r.rank;


SELECT name, category_id, rating_avg
FROM tools
WHERE pricing_type = 'free'
ORDER BY rating_avg DESC
LIMIT 5;


SELECT t.name, GROUP_CONCAT(tg.name SEPARATOR ', ') AS tags
FROM tools t
JOIN tool_tags tt ON t.tool_id = tt.tool_id
JOIN tags tg ON tt.tag_id = tg.tag_id
WHERE t.name = 'Codeium'
GROUP BY t.tool_id;


