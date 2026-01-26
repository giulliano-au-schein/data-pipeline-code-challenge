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

## License

Internal use only - Interview assessment material.
