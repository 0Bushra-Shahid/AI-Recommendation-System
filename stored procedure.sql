DELIMITER $$

CREATE PROCEDURE smart_recommend(
    IN p_user_id INT,
    IN p_query_text VARCHAR(255),
    IN p_category_name VARCHAR(100),
    IN p_prefer_free BOOLEAN
)
BEGIN
    DECLARE v_query_id INT;
    DECLARE v_category_id INT;

    SELECT category_id INTO v_category_id FROM categories WHERE name = p_category_name LIMIT 1;

    INSERT INTO user_queries (user_id, query_text, intent_category) 
    VALUES (p_user_id, p_query_text, p_category_name);
    SET v_query_id = LAST_INSERT_ID();

    INSERT INTO recommendations (query_id, tool_id, score, `rank`)
    SELECT 
        v_query_id,
        t.tool_id,
        ROUND(
            (t.rating_avg / 5 * 40) +
            (LEAST(COALESCE(popularity.interaction_count, 0), 20) / 20 * 30) +
            (CASE WHEN p_prefer_free = TRUE AND t.pricing_type = 'free' THEN 20 ELSE 10 END) +
            10
        , 2) AS final_score,
        ROW_NUMBER() OVER (
            ORDER BY 
                (t.rating_avg / 5 * 40) +
                (LEAST(COALESCE(popularity.interaction_count, 0), 20) / 20 * 30) +
                (CASE WHEN p_prefer_free = TRUE AND t.pricing_type = 'free' THEN 20 ELSE 10 END) +
                10
            DESC
        ) AS `rank`
    FROM tools t
    LEFT JOIN (
        SELECT tool_id, COUNT(*) AS interaction_count
        FROM user_interactions
        GROUP BY tool_id
    ) popularity ON t.tool_id = popularity.tool_id
    WHERE t.category_id = v_category_id
    ORDER BY final_score DESC
    LIMIT 5;

END$$

DELIMITER ;