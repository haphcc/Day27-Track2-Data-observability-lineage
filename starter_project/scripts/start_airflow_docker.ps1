$ErrorActionPreference = "Stop"

$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
$StarterProject = Resolve-Path (Join-Path $RepoRoot "starter_project")
$ContainerName = "day27-airflow"
$DiscordWebhookUrl = $env:DISCORD_WEBHOOK_URL

$existing = docker ps -a --filter "name=^/$ContainerName$" --format "{{.Names}}"
if ($existing -eq $ContainerName) {
    docker rm -f $ContainerName | Out-Null
}

docker run `
    --detach `
    --name $ContainerName `
    --publish 8080:8080 `
    --env AIRFLOW__CORE__LOAD_EXAMPLES=False `
    --env AIRFLOW__CORE__DAGS_FOLDER=/opt/airflow/starter_project/dags `
    --env PYTHONPATH=/opt/airflow/starter_project `
    --env AIRFLOW_INPUT_FILE=/opt/airflow/starter_project/data/orders_passed.csv `
    --env DISCORD_WEBHOOK_URL="$DiscordWebhookUrl" `
    --volume "${StarterProject}:/opt/airflow/starter_project" `
    apache/airflow:3.1.5 `
    standalone

Write-Host "Airflow container started: $ContainerName"
Write-Host "Open http://localhost:8080"
Write-Host "Run this to read generated credentials:"
Write-Host "docker logs $ContainerName | Select-String -Pattern 'username|password|Login'"
