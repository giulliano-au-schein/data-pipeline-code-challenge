# Senior Data Engineer - Candidate Preparation Manual

Welcome! This guide will help you prepare for your upcoming live technical exercise. Read it carefully — the better prepared you are, the more you can focus on demonstrating your engineering skills during the session.

---

## What to Expect

You will work through a **hands-on ELT pipeline challenge** that simulates a real marketplace data platform. The exercise is designed to feel like a day-one task at a new company: you'll receive a partially set up environment with starter code and be asked to build it out into a production-grade pipeline.

**Duration:** 2-3 hours (depending on depth)
**Format:** Live coding session with an interviewer present
**Environment:** Everything runs locally via Docker — no cloud accounts needed

> **Important:** This is not a trick exercise. We want to see how you think, not whether you can memorize syntax. You are encouraged to use documentation, search engines, and reference materials during the session. Ask clarifying questions — that's a sign of a senior engineer.

---

## The Tech Stack

You will work with the following tools. You don't need to be an expert in all of them, but familiarity will help you move faster.

| Technology | Role | What You Should Know |
|------------|------|---------------------|
| **PostgreSQL** | Source database | Basic SQL queries, schema inspection (`\dt`, `\d+ table_name`) |
| **Airbyte** | Extract & Load | Web UI-based configuration of sources, destinations, and sync modes |
| **dbt (Data Build Tool)** | Transform | Models, tests, sources, `ref()`, `source()`, materializations, packages |
| **Apache Airflow** | Orchestration | DAG structure, operators, task dependencies, error handling |
| **BigQuery** (emulator) | Target warehouse | Standard SQL (minor emulator limitations) |
| **Docker Compose** | Infrastructure | `docker-compose up/down/ps/logs`, `docker exec` |

### Recommended Brush-Up Areas

If your experience with any of these tools is rusty, we recommend reviewing:

**dbt (highest priority):**
- Model layers: staging, intermediate, marts
- `source()` and `ref()` functions
- Schema tests (`unique`, `not_null`, `relationships`, `accepted_values`)
- Custom tests
- Incremental materializations (`is_incremental()`, `unique_key`)
- The `dbt_utils` package (especially `deduplicate`)
- CTE-based model structure

**Airflow:**
- DAG definition and `default_args`
- `BashOperator`, `PythonOperator`
- Task groups and dependency chains (`>>`)
- Retry and error handling patterns

**SQL patterns:**
- Window functions (`ROW_NUMBER`, `RANK`, `LAG`/`LEAD`)
- CTEs (Common Table Expressions)
- `COALESCE`, `NULLIF`
- SCD Type 2 concepts
- Deduplication strategies

---

## The Scenario

You're joining a growing **online marketplace platform**. The analytics team needs reliable access to business metrics like GMV (Gross Merchandise Value), seller performance, payment reconciliation, and customer cohorts.

The source PostgreSQL database contains transactional data from the marketplace. Your job is to build a robust ELT pipeline that extracts this data, loads it into a warehouse, and transforms it into analytics-ready tables.

### The Data Model

You will work with these source tables:

| Table | Description | Key Characteristics |
|-------|-------------|---------------------|
| `users` | Buyers and sellers | Soft deletes, optional fields |
| `products` | Marketplace listings | Multi-currency pricing |
| `orders` | Customer transactions | Status tracking, amounts |
| `order_items` | Line items per order | Links orders to products |
| `payments` | Payment events | Event-based, deduplication needed |
| `reviews` | Product ratings | Linked to verified purchases |
| `categories` | Product taxonomy | Hierarchical (parent-child) |
| `seller_tier_history` | Seller progression | Time-series data (SCD Type 2) |
| `event_log` | CDC event stream | Out-of-order events |

### What You'll Build

1. **Airbyte Connection** — Configure source (Postgres) and destination (BigQuery) replication
2. **dbt Models** — Staging, intermediate, and mart layers with tests
3. **Airflow DAG** — Enhance a starter DAG for production readiness
4. **Data Quality Handling** — Identify and resolve issues in the source data
5. **Discussion** — Talk through architectural decisions and trade-offs

---

## How to Prepare

### 1. Get Comfortable with Data Exploration

The first thing you should do in the exercise is **explore the data before writing any code**. Practice these skills:

```bash
# Connect to a Postgres database
psql -U <user> -d <database>

# List all tables
\dt

# Inspect a table's schema
\d+ <table_name>

# Quick data profiling
SELECT COUNT(*) FROM <table>;
SELECT COUNT(DISTINCT column) FROM <table>;
SELECT column, COUNT(*) FROM <table> GROUP BY column ORDER BY 2 DESC;

# Check for NULLs
SELECT COUNT(*) FILTER (WHERE column IS NULL) as null_count FROM <table>;
```

> **Pro tip:** Senior engineers explore before they code. Spending 10 minutes profiling data upfront can save 30 minutes of debugging later.

### 2. Think in Layers

The dbt project follows a standard layered architecture:

```
raw (loaded by Airbyte)
  └── staging (1:1 with source, light cleaning)
        └── intermediate (joins, business logic)
              └── marts (analytics-ready facts & dimensions)
```

Each layer has a purpose:
- **Staging:** Rename columns, cast types, handle NULLs, deduplicate. One model per source table.
- **Intermediate:** Currency conversion, order enrichment, complex joins. Reusable building blocks.
- **Marts:** Final tables consumed by analysts and dashboards. Facts (`fct_`) and dimensions (`dim_`).

### 3. Data Quality is a First-Class Concern

Real-world data is messy. The exercise includes realistic data quality issues that you'll need to identify and handle. Here are the kinds of problems you should be prepared for:

- **Duplicate records** — When the same logical event appears multiple times
- **Late-arriving data** — Records with timestamps that don't match expected patterns
- **Timezone inconsistencies** — Mixing timezone-aware and timezone-naive timestamps
- **Soft deletes** — Records that aren't physically deleted but flagged as inactive
- **Missing values** — Important fields that may be NULL

For each issue, be prepared to:
1. Explain **how you discovered** it
2. Describe your **chosen approach** and why
3. Implement the **solution** in code
4. Add **tests** to catch regressions

### 4. Think Production-Ready

Senior engineers think beyond "does it work?" Consider:

- **Idempotency:** Can the pipeline re-run safely without creating duplicates?
- **Incremental loading:** Are you reprocessing everything each run, or only new/changed data?
- **Error handling:** What happens when a step fails? Does the whole pipeline stop, or can it recover?
- **Monitoring:** What would you watch in production? How would you know something is wrong?
- **Documentation:** Can another engineer understand your decisions from the code and comments?

### 5. Practice the Discussion Topics

At the end of the exercise, you'll discuss architecture and trade-offs. Some themes to think about:

- How would you handle **schema evolution** (new columns, renamed fields)?
- What changes at **100x the current data volume**?
- How would you set up **monitoring and alerting** for this pipeline?
- Walk through **debugging** a data quality issue reported by an analyst
- When would you choose **different tools** (e.g., Fivetran vs. Airbyte, Spark vs. dbt)?

---

## Time Management Tips

The exercise has multiple tasks. Here's a suggested approach:

| Phase | Suggested Time | What to Focus On |
|-------|---------------|------------------|
| Environment setup & data exploration | ~15 min | Verify services, profile source data, understand the schema |
| Airbyte configuration | ~20 min | Source/destination, sync modes, run first sync |
| dbt development | ~60-90 min | Staging models, intermediate, marts, tests |
| Airflow enhancement | ~30 min | DAG improvements, error handling |
| Discussion | ~20 min | Architecture, trade-offs, production thinking |

**Key advice:**
- **Don't try to be perfect.** It's better to have a working pipeline with a few models than a half-finished attempt at everything.
- **Prioritize dbt.** This is where most of the evaluation happens. Focus on clean staging models with tests before moving to marts.
- **Communicate as you go.** Talk through your thinking. If you're stuck, explain what you're trying and ask questions. We value the process, not just the output.
- **Test early, test often.** Run `dbt build` (which does both `run` and `test`) frequently. Don't wait until the end.

---

## Environment Quick Reference

When you arrive, the environment will already be running. Here are the key access points:

| Service | How to Access | Credentials |
|---------|--------------|-------------|
| Airflow UI | http://localhost:8080 | admin / admin |
| Airbyte UI | http://localhost:8000 | (no auth) |
| Source Postgres | `docker exec -it source-postgres psql -U marketplace -d marketplace` | marketplace / marketplace_secret |
| BigQuery Emulator | localhost:9050 | (no auth) |

### Useful Commands

```bash
# Check service health
docker-compose ps

# View logs for a specific service
docker-compose logs <service-name>

# Enter the dbt container
docker exec -it dbt bash

# Run dbt commands inside the container
dbt deps          # Install packages
dbt run           # Run all models
dbt test          # Run all tests
dbt build         # Run + test (recommended)
dbt run --select staging      # Run only staging models
dbt run --select +fct_orders  # Run fct_orders and all upstream dependencies

# Query source Postgres directly
docker exec -it source-postgres psql -U marketplace -d marketplace \
  -c "SELECT * FROM orders LIMIT 5;"
```

### Existing Starter Code

You won't start from zero. The project includes:
- A **dbt project** with configuration, source definitions, one example staging model (`stg_users`), and useful packages (`dbt_utils`, `dbt_expectations`, `codegen`)
- A **seed file** with currency exchange rates for conversions
- An **Airflow DAG** skeleton with TODOs for you to enhance
- A **source schema definition** (`sources.yml`) with basic tests already defined

Use the existing code as a guide for conventions and patterns.

---

## What We're Looking For

We evaluate five dimensions:

| Dimension | What Stands Out |
|-----------|----------------|
| **Data Quality** | Proactive testing, thoughtful NULL handling, robust deduplication |
| **Pipeline Design** | Idempotent runs, incremental loading, proper error handling |
| **Code Quality** | dbt best practices, clear naming, modular structure |
| **Problem-Solving** | Data exploration first, systematic debugging, asking good questions |
| **System Design** | Production mindset, scalability awareness, monitoring considerations |

### What Differentiates Senior Engineers

- **Explore before coding** — Profile the data, understand relationships, spot anomalies
- **Test proactively** — Don't wait for bugs; write tests that catch them
- **Document decisions** — A comment explaining "why" is worth more than one explaining "what"
- **Think in production** — Consider what happens at 3 AM when this pipeline fails
- **Communicate clearly** — Walk us through your reasoning, trade-offs, and alternatives

---

## Pre-Session Checklist

Before your session, make sure:

- [ ] You have **Docker Desktop** installed and running (allocate at least 8 GB of RAM)
- [ ] You have a **code editor** ready (VS Code, IntelliJ, vim — whatever you're comfortable with)
- [ ] You've reviewed the **dbt documentation** (especially [models](https://docs.getdbt.com/docs/build/models), [tests](https://docs.getdbt.com/docs/build/data-tests), and [sources](https://docs.getdbt.com/docs/build/sources))
- [ ] You're comfortable with **basic SQL** window functions and CTEs
- [ ] You have a **terminal** ready for Docker and CLI commands
- [ ] You've read this manual completely

---

## FAQs

**Q: Can I use Google/Stack Overflow during the exercise?**
A: Yes. We expect you to look things up — that's normal engineering work. What we're evaluating is your approach, not your ability to memorize syntax.

**Q: What if I can't finish everything?**
A: That's completely fine. The exercise is intentionally scoped for depth, not just breadth. A well-implemented subset with tests and documentation is better than rushing through everything.

**Q: What if a service is down or something breaks?**
A: Let the interviewer know. We'll troubleshoot together — that's part of real engineering. We won't penalize you for infrastructure issues.

**Q: Should I ask questions during the exercise?**
A: Absolutely. Asking clarifying questions about requirements, data semantics, or business rules is a strong positive signal. Don't make assumptions when you can ask.

**Q: Do I need to memorize the dbt or Airflow syntax?**
A: No. Reference material is fine. Focus on understanding the concepts (what each tool does and why) rather than memorizing exact syntax.

---

**We look forward to working through this with you. Remember: we're evaluating how you think and solve problems, not whether you can produce a perfect solution under time pressure. Good luck!**
