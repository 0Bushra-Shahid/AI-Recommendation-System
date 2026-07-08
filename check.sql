CALL smart_recommend(3, 'best writing tool for me', 'Writing', TRUE);

SELECT uq.query_text, t.name, t.pricing_type, r.score, r.rank
FROM user_queries uq
JOIN recommendations r ON uq.query_id = r.query_id
JOIN tools t ON r.tool_id = t.tool_id
WHERE uq.query_text = 'best writing tool for me'
ORDER BY r.rank;