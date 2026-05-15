from __future__ import annotations

from datetime import datetime
from pathlib import Path
import sys

try:
    from airflow.sdk import DAG
    from airflow.providers.standard.operators.python import PythonOperator
except ImportError:  # pragma: no cover
    try:
        from airflow import DAG
        from airflow.operators.python import PythonOperator
    except ImportError:
        DAG = None
        PythonOperator = None

PROJECT_ROOT = Path(__file__).resolve().parents[1]
if str(PROJECT_ROOT) not in sys.path:
    sys.path.append(str(PROJECT_ROOT))


def validate_orders_task(**context) -> dict:
    from src.config import AIRFLOW_INPUT_FILE, SUMMARY_FILE
    from src.validation import run_lab_check

    dag_run = context.get("dag_run")
    dag_conf = dag_run.conf if dag_run and dag_run.conf else {}
    input_file = Path(dag_conf.get("input_file", AIRFLOW_INPUT_FILE)).expanduser()
    if not input_file.is_absolute():
        project_relative = PROJECT_ROOT / input_file
        input_file = project_relative if project_relative.exists() else input_file.resolve()

    return run_lab_check(
        input_path=input_file,
        output_path=SUMMARY_FILE,
        allow_failure=False,
        skip_discord=False,
    )


if DAG is not None:
    with DAG(
        dag_id="sales_data_quality_pipeline",
        start_date=datetime(2024, 1, 1),
        schedule=None,
        catchup=False,
        tags=["lab", "data-quality", "discord"],
    ) as dag:
        validate_orders = PythonOperator(
            task_id="validate_orders",
            python_callable=validate_orders_task,
        )
else:  # pragma: no cover
    dag = None
