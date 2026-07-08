START TRANSACTION;

-- Step 1: user add
INSERT INTO users (name, email, password_hash) 
VALUES ('Fatima Noor', 'fatima.noor@example.com', 'hashed_pw_21');

SET @new_user_id = LAST_INSERT_ID();

-- Step 2:query save
INSERT INTO user_queries (user_id, query_text, intent_category) 
VALUES (@new_user_id, 'best AI writing tool', 'Writing');

SET @new_query_id = LAST_INSERT_ID();

-- Step 3: recommendations generate 
INSERT INTO recommendations (query_id, tool_id, score, `rank`)
SELECT @new_query_id, tool_id, rating_avg * 20, 
       ROW_NUMBER() OVER (ORDER BY rating_avg DESC)
FROM tools
WHERE category_id = (SELECT category_id FROM categories WHERE name = 'Writing')
ORDER BY rating_avg DESC
LIMIT 3;

COMMIT;

