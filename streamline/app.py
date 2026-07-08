import streamlit as st
import mysql.connector
from mysql.connector 
import os
import Error

# ---------------------------------------------------------
# DATABASE CONFIG — put your own values here
# ---------------------------------------------------------
DB_CONFIG = {
    "host": "localhost",
    "user": "root",
    "password": os.environ.get("DB_PASSWORD", ""),
    "database": "ai_tool_recommendation",
}


def detect_pricing_preference(query_text):
    """
    Looks at the user's typed query and detects a pricing preference
    based on keywords. Returns:
      - "free" if the user wants free tools prioritized
      - "paid" if the user wants paid/premium tools prioritized
      - None if no preference keyword was found (caller can fall back
        to a manual toggle, e.g. a checkbox)
    """
    text = query_text.lower()
    free_keywords = ["free", "no cost", "zero cost", "open source", "opensource"]
    paid_keywords = ["paid", "premium", "subscription", "pro version"]

    if any(word in text for word in free_keywords):
        return "free"
    if any(word in text for word in paid_keywords):
        return "paid"
    return None


def get_connection():
    try:
        return mysql.connector.connect(**DB_CONFIG)
    except Error as e:
        st.error(f"Database connection failed: {e}")
        return None


def get_categories(conn):
    cursor = conn.cursor()
    cursor.execute("SELECT category_id, name FROM categories ORDER BY name;")
    rows = cursor.fetchall()
    cursor.close()
    return rows


def get_top_tools_by_category(conn, category_id, preference, limit=5):
    """
    Ranks tools by a weighted score: rating (40%) + popularity (30%) + base (10%).

    preference is one of: "free", "paid", or None.
    If a preference is given, ONLY tools with that exact pricing_type are
    returned (strict filter) — no freemium/free mixed into a "paid" result
    or vice versa.
    """
    cursor = conn.cursor(dictionary=True)

    pricing_filter = ""
    params = [category_id]

    if preference in ("free", "paid"):
        pricing_filter = "AND t.pricing_type = %s"
        params.append(preference)

    params.append(limit)

    query = f"""
        SELECT
            t.tool_id,
            t.name,
            t.description,
            t.pricing_type,
            t.website_url,
            t.rating_avg,
            COALESCE(pop.interaction_count, 0) AS times_used,
            ROUND(
                (t.rating_avg / 5 * 40) +
                (LEAST(COALESCE(pop.interaction_count, 0), 20) / 20 * 30) +
                10
            , 2) AS final_score
        FROM tools t
        LEFT JOIN (
            SELECT tool_id, COUNT(*) AS interaction_count
            FROM user_interactions
            GROUP BY tool_id
        ) pop ON t.tool_id = pop.tool_id
        WHERE t.category_id = %s
        {pricing_filter}
        ORDER BY final_score DESC
        LIMIT %s;
    """
    cursor.execute(query, tuple(params))
    results = cursor.fetchall()
    cursor.close()
    return results


def save_query_and_recommendations(conn, user_id, query_text, category_id, results):
    """Logs the query and its recommendations, same as the stored procedure did."""
    cursor = conn.cursor()
    cursor.execute(
        "INSERT INTO user_queries (user_id, query_text, intent_category) "
        "SELECT %s, %s, name FROM categories WHERE category_id = %s;",
        (user_id, query_text, category_id),
    )
    query_id = cursor.lastrowid

    for rank, tool in enumerate(results, start=1):
        cursor.execute(
            "INSERT INTO recommendations (query_id, tool_id, score, `rank`) VALUES (%s, %s, %s, %s);",
            (query_id, tool["tool_id"], tool["final_score"], rank),
        )
    conn.commit()
    cursor.close()


# ---------------------------------------------------------
# STREAMLIT UI
# ---------------------------------------------------------
st.set_page_config(page_title="AI Tool Recommender", page_icon="🤖", layout="centered")
st.title("🤖 AI Tool Recommendation System")
st.caption("Tell us what you need, and we'll suggest the best AI tools.")

conn = get_connection()

if conn:
    categories = get_categories(conn)
    category_names = [c[1] for c in categories]
    category_map = {c[1]: c[0] for c in categories}

    with st.form("recommend_form"):
        user_id = st.number_input("User ID (for testing, 1-20)", min_value=1, max_value=20, value=1)
        query_text = st.text_input("Your query", placeholder="e.g. best free coding tool")
        selected_category = st.selectbox("Category", category_names)
        prefer_free_manual = st.checkbox(
            "Boost free tools (used only if your query doesn't mention 'free'/'paid')",
            value=False,
        )
        submitted = st.form_submit_button("Get recommendations")

    if submitted:
        if not query_text.strip():
            st.warning("Please type your query first.")
        else:
            category_id = category_map[selected_category]

            # First try to detect intent from the query text itself.
            # Fall back to the checkbox only if no keyword was found.
            detected_preference = detect_pricing_preference(query_text)
            preference = detected_preference if detected_preference is not None else (
                "free" if prefer_free_manual else None
            )

            results = get_top_tools_by_category(conn, category_id, preference)

            if results:
                save_query_and_recommendations(conn, user_id, query_text, category_id, results)

                if detected_preference == "free":
                    st.caption("Detected from your query: prioritizing free tools.")
                elif detected_preference == "paid":
                    st.caption("Detected from your query: prioritizing paid tools.")

                st.success(f"Top recommendations for '{query_text}':")

                for i, tool in enumerate(results, start=1):
                    with st.container(border=True):
                        st.subheader(f"{i}. {tool['name']}  —  score: {tool['final_score']}")
                        st.write(tool["description"])
                        st.write(
                            f"**Pricing:** {tool['pricing_type']} | "
                            f"**Rating:** {tool['rating_avg']}/5 | "
                            f"**Used:** {tool['times_used']} times"
                        )
                        if tool["website_url"]:
                            st.markdown(f"[Visit website]({tool['website_url']})")
            else:
                if preference:
                    st.info(f"No {preference} tools found in this category yet.")
                else:
                    st.info("No tools found in this category.")

    conn.close()
else:
    st.warning("Could not connect to the database. Check DB_CONFIG at the top of app.py.")