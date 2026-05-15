$ErrorActionPreference = "Stop"

$ContainerName = "day27-airflow"
$existing = docker ps -a --filter "name=^/$ContainerName$" --format "{{.Names}}"
if ($existing -eq $ContainerName) {
    docker rm -f $ContainerName | Out-Null
    Write-Host "Stopped and removed $ContainerName"
} else {
    Write-Host "$ContainerName is not running"
}
