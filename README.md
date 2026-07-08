# 🤖 AI Tool Recommendation System

A database-driven recommendation system that suggests the best AI tools based on category and pricing preference (e.g. *"best free coding tool"* or *"best paid writing assistant"*). Built as a semester project combining relational database design with a live Python web app.

---

## 📌 Overview

This project simulates a real-world recommendation engine:

- A **MySQL** database stores AI tools, categories, tags, users, queries, and recommendation history.
- A **weighted scoring algorithm** ranks tools by rating, popularity, and pricing match.
- A **Streamlit** web app lets users type a query and get live, ranked recommendations.

---

## 🗂️ Database Schema (ERD)

The database has 9 relational tables:

| Table | Purpose |
|---|---|
| `categories` | Tool categories (Coding, Design, Writing, etc.) |
| `tools` | The AI tools themselves (name, pricing, rating, description) |
| `tags` | Descriptive tags (free, open-source, api-available, etc.) |
| `tool_tags` | Many-to-many link between tools and tags |
| `users` | Registered users |
| `user_queries` | Search queries typed by users |
| `recommendations` | Ranked tool recommendations generated per query |
| `user_interactions` | View/click/bookmark/used activity (used for popularity scoring) |
| `reviews` | User ratings and comments on tools |

**Relationships:**
- `categories` 1—* `tools`
- `tools` *—* `tags` (via `tool_tags`)
- `users` 1—* `user_queries` 1—* `recommendations` *—1 `tools`
- `users` 1—* `user_interactions` *—1 `tools`
- `users` 1—* `reviews` *—1 `tools`

---

## ⚙️ Tech Stack

- **Database:** MySQL 8.0
- **Backend / App:** Python, Streamlit, `mysql-connector-python`
- **Tools used:** MySQL Workbench

---

## 🧠 Recommendation Algorithm

Tools are ranked using a weighted score:

```
final_score = (rating / 5 × 40) + (popularity × 30) + (base × 10)
```

- **Rating (40%)** — the tool's average user rating
- **Popularity (30%)** — how often the tool has been viewed/clicked/used, capped and normalized
- **Base (10%)** — flat baseline so every tool has a minimum score

If a user's query mentions **"free"** or **"paid"**, the app detects this automatically and **strictly filters** results to that pricing type — so a "best paid coding tool" search never returns free tools.

---

## 🚀 Getting Started

### 1. Import the database

The full database (schema + all data — 300+ tools across 14 categories) is included in `ai_tool_recommendation_full.sql`.

```bash
mysql -u root -p ai_tool_recommendation < ai_tool_recommendation_full.sql
```

> If the database doesn't exist yet, create it first:
> ```sql
> CREATE DATABASE ai_tool_recommendation;
> ```

### 2. Install dependencies

```bash
cd streamline
pip install -r requirements.txt
```

### 3. Set your database password (kept out of the code for security)

**Windows (PowerShell):**
```powershell
$env:DB_PASSWORD="your_mysql_password"
```

**macOS/Linux:**
```bash
export DB_PASSWORD="your_mysql_password"
```

### 4. Run the app

```bash
python -m streamlit run app.py
```

The app opens in your browser at `http://localhost:8501`.

---

## 📸 How it works

1. Select a category (e.g. "Coding")
2. Type a query (e.g. "best free coding tool")
3. The app detects your pricing intent from the text
4. Top 5 matching tools are shown, ranked by score

---

## 📁 Project Structure

```
Database/
├── streamline/
│   ├── app.py
│   └── requirements.txt
├── ai_tool_recommendation_full.sql   # full database (schema + data)
└── README.md
```

---

## 🎓 Notes

This is a semester project built to demonstrate:
- Relational database design (ERD, foreign keys, constraints)
- SQL stored procedures and transactions
- A practical scoring/ranking algorithm
- Connecting a database to a live Python application

---

## 📄 License

This project is for educational purposes.

---

## Author Name

BUSHRA SHAHID
