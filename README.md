# Senior Data Engineer - Live Technical Exercise

A comprehensive technical assessment environment for evaluating Senior Data Engineer candidates. This exercise simulates a real-world marketplace data pipeline challenge.

## Quick Start

```bash
# Start all services
docker-compose up -d

# Wait for services to initialize (2-3 minutes)
docker-compose ps

# Candidate instructions
open docs/EXERCISE_INSTRUCTIONS.md
```

## Architecture

```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│    Postgres     │────▶│     Airbyte     │────▶│    BigQuery     │
│   (Source DB)   │     │   (Extract &    │     │   (Emulator)    │
│   Port: 5433    │     │     Load)       │     │   Port: 9050    │
└─────────────────┘     │   Port: 8000    │     └────────┬────────┘
                        └─────────────────┘              │
                                                         │
┌─────────────────┐                                      │
│    Airflow      │──────────────────────────────────────┤
│ (Orchestration) │                                      │
│   Port: 8080    │                                      │
└─────────────────┘                                      │
                        ┌─────────────────┐              │
                        │      dbt        │◀─────────────┘
                        │  (Transform)    │
                        │   Container     │
                        └─────────────────┘
```

## Services

| Service | Port | Credentials | Purpose |
|---------|------|-------------|---------|
| Source Postgres | 5433 | marketplace / marketplace_secret | Marketplace transactional data |
| Airbyte UI | 8000 | - | Data replication configuration |
| Airflow UI | 8080 | admin / admin | Pipeline orchestration |
| BigQuery Emulator | 9050 | - | Analytics warehouse |
| dbt | (container) | - | Data transformation |

## Data Model

The source database simulates a marketplace platform with:

- **users** - Buyers and sellers (with soft deletes)
- **products** - Listings with multi-currency pricing
- **orders** - Transactions with status tracking
- **order_items** - Line items per order
- **payments** - Payment events (with intentional duplicates)
- **reviews** - Product ratings
- **categories** - Hierarchical product taxonomy
- **seller_tier_history** - SCD Type 2 for seller progression
- **event_log** - CDC event stream

### Intentional Data Challenges

| Challenge | Table | Description |
|-----------|-------|-------------|
| Duplicate events | payments | Same `event_id` appears multiple times |
| Late-arriving data | products | Some records have future `updated_at` |
| Timezone issues | orders | `confirmed_at` is timezone-naive |
| Soft deletes | users | `deleted_at` field for inactive users |
| Missing data | users | Some have NULL `country_code` |
| Multi-currency | products | USD, EUR, GBP pricing |

## For Interviewers

### Setup Before Interview

```bash
# 1. Start fresh environment
docker-compose down -v
docker-compose up -d

# 2. Verify all services healthy
docker-compose ps

# 3. Pre-load Airbyte UI (slow first load)
open http://localhost:8000

# 4. Verify Postgres data
docker exec -it source-postgres psql -U marketplace -d marketplace -c "SELECT COUNT(*) FROM orders;"
```

### Evaluation Rubric

See `docs/EVALUATION_RUBRIC.md` for detailed scoring criteria.

### Time Allocation (Recommended)

| Phase | Duration | Focus |
|-------|----------|-------|
| Setup & Exploration | 15 min | Environment, data discovery |
| Airbyte Configuration | 20 min | Source/dest setup, sync modes |
| dbt Development | 60-90 min | Models, tests, documentation |
| Airflow Enhancement | 30 min | DAG improvements |
| Discussion | 20 min | Architecture, trade-offs |

### Key Observation Points

1. **Data Discovery:** Do they explore the schema before coding?
2. **Quality First:** Do they add tests proactively?
3. **Deduplication:** How do they handle the payments trap?
4. **Documentation:** Do they document decisions?
5. **Production Thinking:** Do they consider monitoring/alerting?

## Troubleshooting

### Services Won't Start

```bash
# Check for port conflicts
lsof -i :5433
lsof -i :8000
lsof -i :8080

# View logs
docker-compose logs airflow-init
docker-compose logs source-postgres
```

### Airbyte Connection Issues

```bash
# Verify Postgres is accessible from Airbyte network
docker exec -it airbyte-server ping source-postgres

# Check Airbyte logs
docker-compose logs airbyte-server
```

### dbt Can't Connect to BigQuery

```bash
# Verify emulator is running
curl http://localhost:9050

# Check emulator logs
docker-compose logs bigquery-emulator
```

## Querying the BigQuery Emulator

The BigQuery emulator ([goccy/bigquery-emulator](https://github.com/goccy/bigquery-emulator)) runs locally and exposes the same REST/gRPC APIs as real BigQuery. Three datasets are pre-created: `raw`, `staging`, and `marts` under project `marketplace-analytics`.

### Method 1: REST API (curl)

Query directly from the host machine — no authentication required.

```bash
# List datasets
curl -s http://localhost:9050/bigquery/v2/projects/marketplace-analytics/datasets | python3 -m json.tool

# Run a SQL query
curl -s -X POST 'http://localhost:9050/bigquery/v2/projects/marketplace-analytics/queries' \
  -H 'Content-Type: application/json' \
  -d '{"query":"SELECT 42 AS answer","useLegacySql":false}' | python3 -m json.tool
```

### Method 2: Python Client (inside containers)

Use `google-cloud-bigquery` with `AnonymousCredentials` and the `BIGQUERY_EMULATOR_HOST` env var.

```python
import os
os.environ["BIGQUERY_EMULATOR_HOST"] = "http://bigquery-emulator:9050"

from google.auth.credentials import AnonymousCredentials
from google.cloud import bigquery

client = bigquery.Client(
    project="marketplace-analytics",
    credentials=AnonymousCredentials(),
)

# List datasets
for ds in client.list_datasets():
    print(ds.dataset_id)

# Run a query
rows = client.query("SELECT * FROM raw.my_table").result()
for row in rows:
    print(dict(row))
```

Run interactively from the dbt container:

```bash
docker exec -e BIGQUERY_EMULATOR_HOST=http://bigquery-emulator:9050 dbt python3 -c "
from google.auth.credentials import AnonymousCredentials
from google.cloud import bigquery
client = bigquery.Client(project='marketplace-analytics', credentials=AnonymousCredentials())
for ds in client.list_datasets():
    print(ds.dataset_id)
"
```

### Method 3: dbt

dbt connects via `dbt-bigquery` adapter. The connection is configured in `dbt/profiles.yml` and uses the `BIGQUERY_EMULATOR_HOST` env var set on the dbt container.

```bash
# Run dbt models
docker exec -e BIGQUERY_EMULATOR_HOST=http://bigquery-emulator:9050 dbt dbt run

# Test models
docker exec -e BIGQUERY_EMULATOR_HOST=http://bigquery-emulator:9050 dbt dbt test
```

### Emulator Limitations

| Limitation | Detail |
|---|---|
| `INFORMATION_SCHEMA` | Not supported — use REST API to list datasets/tables |
| `INSERT` statements | Must specify explicit column list (e.g., `INSERT INTO t (col1, col2) VALUES (...)`) |
| `CREATE TABLE IF NOT EXISTS` | May not work reliably — use `CREATE TABLE` and handle errors |
| Platform | Only published as `linux/amd64` — runs under emulation on Apple Silicon |
| Authentication | Accepts any credentials — use `AnonymousCredentials` for simplicity |

### Initial Data Configuration

Datasets are defined in `bigquery/data.yaml`, mounted into the container. To add pre-seeded tables, extend the YAML:

```yaml
projects:
  - id: marketplace-analytics
    datasets:
      - id: raw
        tables:
          - id: example_table
            columns:
              - name: id
                type: INTEGER
              - name: name
                type: STRING
            data:
              - id: 1
                name: "test"
      - id: staging
      - id: marts
```

## License

Internal use only - Interview assessment material.
