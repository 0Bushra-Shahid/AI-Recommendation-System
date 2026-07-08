CREATE DATABASE ai_tool_recommendation;
USE ai_tool_recommendation;

-- CATEGORIES
CREATE TABLE categories (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- USERS
CREATE TABLE users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- TOOLS
CREATE TABLE tools (
    tool_id INT AUTO_INCREMENT PRIMARY KEY,
    category_id INT,
    name VARCHAR(150) NOT NULL,
    description TEXT,
    pricing_type ENUM('free', 'freemium', 'paid') NOT NULL,
    website_url VARCHAR(255),
    rating_avg DECIMAL(3,2) DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (category_id) REFERENCES categories(category_id)
);

-- TAGS
CREATE TABLE tags (
    tag_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE
);

-- TOOL_TAGS (junction table)
CREATE TABLE tool_tags (
    tool_id INT,
    tag_id INT,
    PRIMARY KEY (tool_id, tag_id),
    FOREIGN KEY (tool_id) REFERENCES tools(tool_id) ON DELETE CASCADE,
    FOREIGN KEY (tag_id) REFERENCES tags(tag_id) ON DELETE CASCADE
);

-- USER_QUERIES
CREATE TABLE user_queries (
    query_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    query_text VARCHAR(255) NOT NULL,
    intent_category VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);

-- RECOMMENDATIONS
CREATE TABLE recommendations (
    recommendation_id INT AUTO_INCREMENT PRIMARY KEY,
    query_id INT,
    tool_id INT,
    score DECIMAL(5,2),
    `rank` INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (query_id) REFERENCES user_queries(query_id) ON DELETE CASCADE,
    FOREIGN KEY (tool_id) REFERENCES tools(tool_id) ON DELETE CASCADE
);

-- USER_INTERACTIONS
CREATE TABLE user_interactions (
    interaction_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    tool_id INT,
    interaction_type ENUM('view', 'click', 'bookmark', 'used') NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (tool_id) REFERENCES tools(tool_id)
);

-- REVIEWS
CREATE TABLE reviews (
    review_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    tool_id INT,
    rating INT CHECK (rating BETWEEN 1 AND 5),
    comment TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (tool_id) REFERENCES tools(tool_id)
);