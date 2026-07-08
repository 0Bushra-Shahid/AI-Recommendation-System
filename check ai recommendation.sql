SELECT 
    uq.query_text,
    t.name AS recommended_tool,
    t.pricing_type,
    r.score,
    r.rank
FROM user_queries uq
JOIN recommendations r ON uq.query_id = r.query_id
JOIN tools t ON r.tool_id = t.tool_id
WHERE uq.query_text = 'best free coding tool'
ORDER BY r.rank;