param(
    [Parameter(Mandatory = $true)]
    [string]$BaseUrl,
    [string]$Username,
    [string]$Password,
    [int]$TimeoutSec = 30
)

$ErrorActionPreference = "Stop"

function Normalize-BaseUrl {
    param([string]$Url)
    return $Url.TrimEnd("/")
}

function Get-HealthUrl {
    param([string]$Url)
    $uri = [System.Uri]$Url
    return "{0}://{1}/healthz" -f $uri.Scheme, $uri.Authority
}

function Get-ResponseText {
    param($Content)

    if ($Content -is [byte[]]) {
        return [System.Text.Encoding]::UTF8.GetString($Content)
    }

    return [string]$Content
}

$baseUrl = Normalize-BaseUrl -Url $BaseUrl
$healthUrl = Get-HealthUrl -Url $baseUrl

Write-Host "Validando healthz em $healthUrl"
$health = Invoke-WebRequest -UseBasicParsing -TimeoutSec $TimeoutSec -Uri $healthUrl
if ($health.StatusCode -ne 200 -or (Get-ResponseText $health.Content).Trim() -ne "ok") {
    throw "Healthcheck falhou em $healthUrl"
}

Write-Host "Healthcheck OK"

if (-not $Username -or -not $Password) {
    Write-Warning "Username/password nao informados. Validacao autenticada foi pulada."
    exit 0
}

$headers = @{
    "Content-Type" = "application/json"
    "Accept" = "application/json"
}

$loginBody = @{
    login = $Username
    password = $Password
} | ConvertTo-Json

$initUrl = "$baseUrl/initSession"
Write-Host "Validando initSession em $initUrl"
$session = Invoke-RestMethod -TimeoutSec $TimeoutSec -Method POST -Uri $initUrl -Headers $headers -Body $loginBody
$sessionToken = $session.session_token

if (-not $sessionToken) {
    throw "initSession nao retornou session_token"
}

Write-Host "initSession OK"

$authHeaders = @{
    "Accept" = "application/json"
    "Session-Token" = $sessionToken
}

$fullSessionUrl = "$baseUrl/getFullSession"
Write-Host "Validando getFullSession em $fullSessionUrl"
$fullSession = Invoke-RestMethod -TimeoutSec $TimeoutSec -Method GET -Uri $fullSessionUrl -Headers $authHeaders
if (-not $fullSession) {
    throw "getFullSession retornou vazio"
}

Write-Host "getFullSession OK"

$killUrl = "$baseUrl/killSession"
Write-Host "Encerrando sessao em $killUrl"
Invoke-RestMethod -TimeoutSec $TimeoutSec -Method GET -Uri $killUrl -Headers $authHeaders | Out-Null
Write-Host "killSession OK"
