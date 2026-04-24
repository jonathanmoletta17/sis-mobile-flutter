param(
    [Parameter(Mandatory = $true)]
    [string]$ApiToken,
    [Parameter(Mandatory = $true)]
    [string]$AccountId,
    [string]$ZoneId
)

$ErrorActionPreference = "Stop"

function Invoke-CfApi {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Method,
        [Parameter(Mandatory = $true)]
        [string]$Uri
    )

    try {
        return Invoke-RestMethod `
            -Method $Method `
            -Uri $Uri `
            -Headers @{ Authorization = "Bearer $ApiToken" } `
            -ContentType "application/json"
    } catch {
        $body = $null
        if ($_.Exception.Response) {
            $reader = New-Object System.IO.StreamReader(
                $_.Exception.Response.GetResponseStream()
            )
            try {
                $body = $reader.ReadToEnd()
            } finally {
                $reader.Dispose()
            }
        }

        if ($body) {
            throw "Cloudflare API falhou em $Uri :: $body"
        }

        throw
    }
}

$publicIp = (Invoke-RestMethod -Uri "https://api.ipify.org?format=json").ip
$verify = Invoke-CfApi -Method GET -Uri "https://api.cloudflare.com/client/v4/user/tokens/verify"
$account = Invoke-CfApi -Method GET -Uri "https://api.cloudflare.com/client/v4/accounts/$AccountId"
$tunnels = Invoke-CfApi -Method GET -Uri "https://api.cloudflare.com/client/v4/accounts/$AccountId/cfd_tunnel?is_deleted=false"

$zone = $null
if ($ZoneId) {
    $zone = Invoke-CfApi -Method GET -Uri "https://api.cloudflare.com/client/v4/zones/$ZoneId"
}

[pscustomobject]@{
    public_ip = $publicIp
    token_status = $verify.result.status
    token_id = $verify.result.id
    account_id = $AccountId
    account_name = $account.result.name
    tunnel_count = @($tunnels.result).Count
    zone_id = $zone.result.id
    zone_name = $zone.result.name
} | ConvertTo-Json -Depth 8
