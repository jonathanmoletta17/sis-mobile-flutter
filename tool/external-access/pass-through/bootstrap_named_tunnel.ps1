param(
    [Parameter(Mandatory = $true)]
    [string]$ApiToken,
    [Parameter(Mandatory = $true)]
    [string]$AccountId,
    [Parameter(Mandatory = $true)]
    [string]$ZoneId,
    [Parameter(Mandatory = $true)]
    [string]$Hostname,
    [string]$TunnelName = "sis-mobile-pass-through",
    [string]$TunnelId,
    [string]$ServiceUrl = "http://sis-pass-through:8080",
    [switch]$WriteEnvFile
)

$ErrorActionPreference = "Stop"

function Invoke-CfApi {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Method,
        [Parameter(Mandatory = $true)]
        [string]$Uri,
        [object]$Body
    )

    $params = @{
        Method = $Method
        Uri = $Uri
        Headers = @{ Authorization = "Bearer $ApiToken" }
        ContentType = "application/json"
    }

    if ($null -ne $Body) {
        $params.Body = ($Body | ConvertTo-Json -Depth 12)
    }

    try {
        return Invoke-RestMethod @params
    } catch {
        $bodyText = $null
        if ($_.Exception.Response) {
            $reader = New-Object System.IO.StreamReader(
                $_.Exception.Response.GetResponseStream()
            )
            try {
                $bodyText = $reader.ReadToEnd()
            } finally {
                $reader.Dispose()
            }
        }

        if ($bodyText) {
            throw "Cloudflare API falhou em $Uri :: $bodyText"
        }

        throw
    }
}

function Write-Utf8NoBomFile {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,
        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [string]$Content
    )

    $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($Path, $Content, $utf8NoBom)
}

$repoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..\..")
$envHostPath = Join-Path $PSScriptRoot ".env.host"

$tunnelId = $TunnelId

if (-not $tunnelId) {
    $createTunnel = Invoke-CfApi `
        -Method POST `
        -Uri "https://api.cloudflare.com/client/v4/accounts/$AccountId/cfd_tunnel" `
        -Body @{
            name = $TunnelName
            config_src = "cloudflare"
        }

    $tunnelId = $createTunnel.result.id
}

Invoke-CfApi `
    -Method PUT `
    -Uri "https://api.cloudflare.com/client/v4/accounts/$AccountId/cfd_tunnel/$tunnelId/configurations" `
    -Body @{
        config = @{
            ingress = @(
                @{
                    hostname = $Hostname
                    service = $ServiceUrl
                    originRequest = @{}
                },
                @{
                    service = "http_status:404"
                }
            )
        }
    } | Out-Null

$existingDns = Invoke-CfApi `
    -Method GET `
    -Uri "https://api.cloudflare.com/client/v4/zones/$ZoneId/dns_records?type=CNAME&name=$Hostname"

$dnsBody = @{
    type = "CNAME"
    proxied = $true
    name = $Hostname
    content = "$tunnelId.cfargotunnel.com"
}

if (@($existingDns.result).Count -gt 0) {
    $dnsRecordId = $existingDns.result[0].id
    Invoke-CfApi `
        -Method PUT `
        -Uri "https://api.cloudflare.com/client/v4/zones/$ZoneId/dns_records/$dnsRecordId" `
        -Body $dnsBody | Out-Null
} else {
    Invoke-CfApi `
        -Method POST `
        -Uri "https://api.cloudflare.com/client/v4/zones/$ZoneId/dns_records" `
        -Body $dnsBody | Out-Null
}

$tunnelTokenResponse = Invoke-CfApi `
    -Method GET `
    -Uri "https://api.cloudflare.com/client/v4/accounts/$AccountId/cfd_tunnel/$tunnelId/token"

$tunnelToken = $tunnelTokenResponse.result

if ($WriteEnvFile) {
    if (-not (Test-Path $envHostPath)) {
        throw "Arquivo nao encontrado para escrita: $envHostPath"
    }

    $envData = [ordered]@{}
    Get-Content -LiteralPath $envHostPath | ForEach-Object {
        if ($_ -match '^\s*#') { return }
        if ($_ -match '^\s*$') { return }
        $parts = $_ -split '=', 2
        if ($parts.Length -eq 2) {
            $envData[$parts[0]] = $parts[1]
        }
    }

    $envData["PUBLIC_HOSTNAME"] = $Hostname
    $envData["CLOUDFLARE_TUNNEL_TOKEN"] = $tunnelToken

    $content = ($envData.GetEnumerator() | ForEach-Object {
        "{0}={1}" -f $_.Key, $_.Value
    }) -join [Environment]::NewLine

    Write-Utf8NoBomFile -Path $envHostPath -Content ($content + [Environment]::NewLine)
}

[pscustomobject]@{
    hostname = $Hostname
    account_id = $AccountId
    zone_id = $ZoneId
    tunnel_id = $tunnelId
    tunnel_name = $TunnelName
    tunnel_id_supplied = [bool]$TunnelId
    service_url = $ServiceUrl
    env_host_written = [bool]$WriteEnvFile
    tunnel_token_preview = if ($tunnelToken.Length -gt 16) {
        "{0}...{1}" -f $tunnelToken.Substring(0, 8), $tunnelToken.Substring($tunnelToken.Length - 8)
    } else {
        "***"
    }
} | ConvertTo-Json -Depth 8
