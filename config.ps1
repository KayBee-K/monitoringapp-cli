# config.ps1 - Helper functions for MonitoringApp CLI (PowerShell)

$script:BASE_URL   = "https://monitoring-app.on-forge.com"
$script:AUTH_TOKEN = ""

# ── Colored output ───────────────────────────────────────────────────────────

function Print-Success { param($msg) Write-Host "[SUCCÈS] $msg"           -ForegroundColor Green  }
function Print-Error   { param($msg) Write-Host "[ERREUR] $msg"            -ForegroundColor Red    }
function Print-Warn    { param($msg) Write-Host "[AVERTISSEMENT] $msg"     -ForegroundColor Yellow }
function Print-Info    { param($msg) Write-Host "[INFO] $msg"              -ForegroundColor Cyan   }

function Print-Header {
    param($title)
    Write-Host ""
    Write-Host "=== $title ===" -ForegroundColor Blue
    Write-Host ""
}

# ── Session helpers ───────────────────────────────────────────────────────────

function Require-Auth {
    if ([string]::IsNullOrEmpty($script:AUTH_TOKEN)) {
        Print-Error "Non connecté. Veuillez vous connecter d'abord (option 1)."
        return $false
    }
    return $true
}

function Press-Enter {
    Write-Host "`nAppuyez sur Entrée pour continuer..." -ForegroundColor Cyan
    Read-Host | Out-Null
}

# ── Input validation ──────────────────────────────────────────────────────────

function Validate-NotEmpty {
    param($value, $field)
    if ([string]::IsNullOrWhiteSpace($value)) {
        Print-Error "$field ne peut pas être vide."
        return $false
    }
    return $true
}

function Validate-Id {
    param($id)
    if ([string]::IsNullOrWhiteSpace($id) -or $id -notmatch '^[0-9a-fA-F\-]+$') {
        Print-Error "L'ID doit être un nombre ou un UUID valide."
        return $false
    }
    return $true
}

function Confirm-Destructive {
    param($message = "Êtes-vous sûr(e)?")
    Write-Host "$message (o/n): " -ForegroundColor Yellow -NoNewline
    $answer = Read-Host
    if ($answer -match '^[Oo]') { return $true }
    Print-Warn "Opération annulée."
    return $false
}

# ── JSON pretty-print ─────────────────────────────────────────────────────────

function Pretty-Json {
    param($raw)
    if ([string]::IsNullOrWhiteSpace($raw)) { Write-Host "(réponse vide)"; return }
    try {
        $raw | ConvertFrom-Json | ConvertTo-Json -Depth 10 | Write-Host
    } catch {
        Write-Host $raw
    }
}

# ── HTTP helpers ──────────────────────────────────────────────────────────────
# Returns the raw response body string in all cases (success or error).

function Invoke-Api {
    param(
        [string]$Method,
        [string]$Endpoint,
        [string]$Body   = "",
        [switch]$NoAuth          # used for login
    )

    $headers = @{ "Content-Type" = "application/json" }
    if (-not $NoAuth -and -not [string]::IsNullOrEmpty($script:AUTH_TOKEN)) {
        $headers["Authorization"] = "Bearer $script:AUTH_TOKEN"
    }

    $params = @{
        Uri             = "$script:BASE_URL$Endpoint"
        Method          = $Method
        Headers         = $headers
        UseBasicParsing = $true
        ErrorAction     = "Stop"
    }
    if (-not [string]::IsNullOrEmpty($Body)) {
        $params["Body"] = $Body
    }

    try {
        $response = Invoke-WebRequest @params
        return $response.Content
    } catch {
        # Try to read the error body from the response stream
        try {
            $stream = $_.Exception.Response.GetResponseStream()
            $reader = [System.IO.StreamReader]::new($stream)
            return $reader.ReadToEnd()
        } catch {
            return '{"success":false,"message":"' + ($_.Exception.Message -replace '"','\"') + '"}'
        }
    }
}

function Api-Get    { param($ep)           Invoke-Api -Method GET    -Endpoint $ep }
function Api-Post   { param($ep, $body)    Invoke-Api -Method POST   -Endpoint $ep -Body $body }
function Api-Put    { param($ep, $body)    Invoke-Api -Method PUT    -Endpoint $ep -Body $body }
function Api-Patch  { param($ep, $body)    Invoke-Api -Method PATCH  -Endpoint $ep -Body $body }
function Api-Delete { param($ep)           Invoke-Api -Method DELETE -Endpoint $ep }
