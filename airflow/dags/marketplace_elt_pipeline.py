"""
Marketplace ELT Pipeline - Senior Data Engineer Exercise

This DAG orchestrates the full ELT pipeline:
1. Trigger Airbyte sync (Postgres -> BigQuery raw)
2. Run dbt transformations (raw -> staging -> marts)
3. Run data quality checks

CANDIDATE TASK: This is a STARTER DAG. You should enhance it with:
- Proper error handling and retries
- Alerting on failures
- Incremental loading logic
- Data quality gates
- Proper dependency management
"""

from datetime import datetime, timedelta
from airflow import DAG
from airflow.operators.bash import BashOperator
from airflow.operators.python import PythonOperator
from airflow.operators.empty import EmptyOperator
from airflow.utils.task_group import TaskGroup

# =============================================================================
# DAG Configuration
# =============================================================================
default_args = {
    'owner': 'data-engineering',
    'depends_on_past': False,
    'email_on_failure': False,
    'email_on_retry': False,
    'retries': 1,
    'retry_delay': timedelta(minutes=5),
}

# =============================================================================
# DAG Definition
# =============================================================================
with DAG(
    dag_id='marketplace_elt_pipeline',
    default_args=default_args,
    description='Marketplace data pipeline: Airbyte (EL) + dbt (T)',
    schedule_interval='@hourly',
    start_date=datetime(2024, 1, 1),
    catchup=False,
    tags=['marketplace', 'elt', 'production'],
    doc_md=__doc__,
) as dag:

    # =========================================================================
    # Start Task
    # =========================================================================
    start = EmptyOperator(task_id='start')

    # =========================================================================
    # Extract & Load (Airbyte)
    # =========================================================================
    with TaskGroup(group_id='extract_load') as extract_load:
        """
        CANDIDATE TODO:
        - Replace with proper Airbyte operator or API call
        - Add connection health check
        - Implement incremental sync logic
        """

        trigger_airbyte_sync = BashOperator(
            task_id='trigger_airbyte_sync',
            bash_command='''
                echo "Triggering Airbyte sync..."
                # TODO: Replace with actual Airbyte API call
                # curl -X POST http://airbyte-server:8001/api/v1/connections/sync \
                #   -H "Content-Type: application/json" \
                #   -d '{"connectionId": "YOUR_CONNECTION_ID"}'
                echo "Airbyte sync completed (simulated)"
            ''',
        )

        verify_raw_data = BashOperator(
            task_id='verify_raw_data',
            bash_command='''
                echo "Verifying raw data loaded..."
                # TODO: Add data quality checks on raw layer
                # - Row counts
                # - Schema validation
                # - Freshness checks
                echo "Raw data verification passed (simulated)"
            ''',
        )

        trigger_airbyte_sync >> verify_raw_data

    # =========================================================================
    # Transform (dbt)
    # =========================================================================
    with TaskGroup(group_id='transform') as transform:
        """
        CANDIDATE TODO:
        - Add proper dbt operator (dbt Cloud or dbt-airflow)
        - Implement model selection for incremental runs
        - Add dbt test results to Airflow XCom
        """

        dbt_deps = BashOperator(
            task_id='dbt_deps',
            bash_command='cd /opt/airflow/dbt && dbt deps',
        )

        dbt_run_staging = BashOperator(
            task_id='dbt_run_staging',
            bash_command='cd /opt/airflow/dbt && dbt run --select staging',
        )

        dbt_test_staging = BashOperator(
            task_id='dbt_test_staging',
            bash_command='cd /opt/airflow/dbt && dbt test --select staging',
        )

        dbt_run_intermediate = BashOperator(
            task_id='dbt_run_intermediate',
            bash_command='cd /opt/airflow/dbt && dbt run --select intermediate',
        )

        dbt_run_marts = BashOperator(
            task_id='dbt_run_marts',
            bash_command='cd /opt/airflow/dbt && dbt run --select marts',
        )

        dbt_test_marts = BashOperator(
            task_id='dbt_test_marts',
            bash_command='cd /opt/airflow/dbt && dbt test --select marts',
        )

        (
            dbt_deps
            >> dbt_run_staging
            >> dbt_test_staging
            >> dbt_run_intermediate
            >> dbt_run_marts
            >> dbt_test_marts
        )

    # =========================================================================
    # Data Quality & Validation
    # =========================================================================
    with TaskGroup(group_id='quality_checks') as quality_checks:
        """
        CANDIDATE TODO:
        - Implement comprehensive data quality checks
        - Add anomaly detection
        - Create data quality dashboard metrics
        """

        check_row_counts = BashOperator(
            task_id='check_row_counts',
            bash_command='''
                echo "Checking row counts..."
                # TODO: Query marts and validate expected ranges
                echo "Row count validation passed (simulated)"
            ''',
        )

        check_freshness = BashOperator(
            task_id='check_freshness',
            bash_command='cd /opt/airflow/dbt && dbt source freshness',
        )

        check_row_counts
        check_freshness

    # =========================================================================
    # End Task
    # =========================================================================
    end = EmptyOperator(task_id='end')

    # =========================================================================
    # Task Dependencies
    # =========================================================================
    start >> extract_load >> transform >> quality_checks >> end
