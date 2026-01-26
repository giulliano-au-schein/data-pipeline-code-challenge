# Senior Data Engineer - Live Technical Exercise

## Overview

Welcome to the technical assessment for the Senior Data Engineer position. This exercise evaluates your ability to design and implement a production-grade data pipeline for a marketplace platform.

**Duration:** 2-3 hours (depending on depth of implementation)

**Stack:**
- **Source:** PostgreSQL (marketplace transactional data)
- **EL Tool:** Airbyte
- **Orchestration:** Apache Airflow
- **Transformation:** dbt
- **Target:** BigQuery (emulator)

---

## Scenario

You've joined a growing marketplace platform. The analytics team needs reliable access to key business metrics:

1. **Daily GMV (Gross Merchandise Value)** by region and category
2. **Seller performance dashboard** with tier progression tracking
3. **Payment reconciliation** report for finance
4. **Customer cohort analysis** for marketing

The source PostgreSQL database contains live transactional data. Your task is to build a robust ELT pipeline that:
- Extracts data incrementally
- Handles common data quality issues
- Produces analytics-ready tables

---

## Getting Started

### 1. Start the Environment

```bash
# Clone and navigate to project
cd data-pipeline-code-challenge

# Start all services
docker-compose up -d

# Verify services are running
docker-compose ps
```

### 2. Access Points

| Service | URL | Credentials |
|---------|-----|-------------|
| Airflow | http://localhost:8080 | admin / admin |
| Airbyte | http://localhost:8000 | - |
| Source Postgres | localhost:5433 | marketplace / marketplace_secret |
| BigQuery Emulator | localhost:9050 | - |

### 3. Explore the Source Data

```bash
# Connect to source database
docker exec -it source-postgres psql -U marketplace -d marketplace

# List tables
\dt

# Explore schema
\d+ orders
```

---

## Tasks

### Task 1: Configure Airbyte Connection (20 min)

**Objective:** Set up data replication from Postgres to BigQuery

1. Access Airbyte UI at http://localhost:8000
2. Configure source: PostgreSQL
   - Host: `source-postgres`
   - Port: `5432`
   - Database: `marketplace`
   - User: `marketplace`
   - Password: `marketplace_secret`
3. Configure destination: BigQuery (emulator)
   - Project: `marketplace-analytics`
   - Dataset: `raw`
4. Create connection with appropriate sync mode
   - **Consider:** Which tables need full refresh vs incremental?
   - **Consider:** What's the appropriate sync frequency?

**Deliverable:** Working Airbyte connection syncing all tables

---

### Task 2: Build dbt Transformation Layer (60-90 min)

**Objective:** Create a well-structured dbt project with staging, intermediate, and mart models

#### 2a. Staging Models

Create staging models for all source tables in `models/staging/`:
- Apply consistent naming conventions
- Cast data types appropriately
- Handle NULL values
- **IMPORTANT:** The `payments` table contains duplicate events - handle this!

#### 2b. Intermediate Models

Create intermediate models in `models/intermediate/` for complex transformations:
- Currency normalization (convert all amounts to USD)
- Order enrichment (join order details)
- Seller tier SCD Type 2 (use `seller_tier_history`)

#### 2c. Mart Models

Create analytics-ready models in `models/marts/`:

| Model | Description | Key Metrics |
|-------|-------------|-------------|
| `fct_orders` | Order fact table | GMV, order count, AOV |
| `fct_daily_sales` | Daily aggregated sales | Revenue by day/region/category |
| `dim_users` | User dimension | User attributes, seller tier |
| `dim_products` | Product dimension | Product attributes, category hierarchy |
| `fct_seller_performance` | Seller metrics | GMV, order count, rating, tier |

#### 2d. Data Quality Tests

Add dbt tests in `schema.yml` and custom tests in `tests/`:
- Uniqueness and not-null on keys
- Referential integrity
- Business rule validation (e.g., total_amount = subtotal + shipping + tax - discount)
- **BONUS:** Create a custom test for payment deduplication

**Deliverable:** Complete dbt project with passing `dbt build`

---

### Task 3: Orchestrate with Airflow (30 min)

**Objective:** Enhance the starter DAG for production readiness

Review `airflow/dags/marketplace_elt_pipeline.py` and implement:

1. **Proper Airbyte trigger** using Airbyte API or operator
2. **Error handling** with appropriate retries and alerts
3. **Data quality gates** that block downstream processing on failures
4. **Incremental logic** for efficient daily runs
5. **Documentation** for on-call engineers

**Deliverable:** Production-ready Airflow DAG

---

### Task 4: Handle Data Quality Issues (20-30 min)

The source data contains several intentional issues. Document how you identified and handled:

1. **Duplicate payment events** (same `event_id`, different `payment_id`)
2. **Late-arriving data** (some products have future `updated_at`)
3. **Timezone inconsistencies** (`orders.confirmed_at` is timezone-naive)
4. **Soft deletes** (users with `deleted_at` populated)
5. **Missing data** (some users have NULL `country_code`)

**Deliverable:** Documentation of your approach + implemented solutions

---

### Task 5: Discussion (15-20 min)

Be prepared to discuss:

1. **Schema evolution:** How would you handle a new column added to `products`?
2. **Scalability:** What changes for 100x data volume?
3. **Monitoring:** What metrics would you track in production?
4. **Incident response:** An analyst reports duplicate orders in the mart. Walk through your debugging process.
5. **Alternative approaches:** When would you choose Fivetran over Airbyte? Spark over dbt?

---

## Evaluation Criteria

| Dimension | Weight | What We Look For |
|-----------|--------|------------------|
| **Data Quality** | 25% | Tests, NULL handling, deduplication, validation |
| **Pipeline Design** | 25% | Idempotency, incremental loading, error handling |
| **Code Quality** | 20% | dbt best practices, documentation, modularity |
| **Problem-Solving** | 15% | How you discover and handle edge cases |
| **System Design** | 15% | Scalability considerations, production readiness |

### What Differentiates Senior Engineers

- **Proactive data quality:** Don't wait for issues - test for them
- **Production mindset:** Think about monitoring, alerting, runbooks
- **Clear communication:** Document decisions and trade-offs
- **Pragmatic solutions:** Balance perfection with shipping

---

## Hints & Resources

### Quick Reference Commands

```bash
# dbt commands (run from dbt container)
docker exec -it dbt bash
dbt deps
dbt run --select staging
dbt test
dbt build  # run + test

# Check Postgres data
docker exec -it source-postgres psql -U marketplace -d marketplace -c "SELECT * FROM orders LIMIT 5;"

# View Airflow logs
docker logs -f airflow-scheduler
```

### BigQuery Emulator Notes

The BigQuery emulator has limitations:
- Some advanced SQL features may not work
- Use `marketplace-analytics` as project ID
- Datasets: `raw`, `staging`, `marts`

### Useful dbt Patterns

```sql
-- Deduplication pattern
{{ dbt_utils.deduplicate(
    relation=source('raw_marketplace', 'payments'),
    partition_by='event_id',
    order_by='event_timestamp desc'
) }}

-- Currency conversion
{{ var('usd_to_eur') }}  -- Access project variable

-- Incremental model
{{ config(materialized='incremental', unique_key='id') }}
{% if is_incremental() %}
  WHERE updated_at > (SELECT MAX(updated_at) FROM {{ this }})
{% endif %}
```

---

## Submission

When complete, ensure:

1. [ ] All dbt models build successfully (`dbt build`)
2. [ ] Airbyte connection is configured and synced
3. [ ] Airflow DAG is functional
4. [ ] Data quality issues are documented and handled
5. [ ] Code is clean and documented

**Good luck!** Focus on demonstrating your problem-solving process, not just the final output. We value seeing how you think through challenges.
