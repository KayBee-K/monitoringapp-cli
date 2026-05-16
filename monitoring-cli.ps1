# monitoring-cli.ps1 - Interactive CLI for MonitoringApp API (PowerShell)
# Run with:  powershell -ExecutionPolicy Bypass -File .\monitoring-cli.ps1

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
. "$ScriptDir\config.ps1"

# ── AUTH ──────────────────────────────────────────────────────────────────────

function Do-Login {
    Print-Header "Connexion"
    $email    = Read-Host "E-mail"
    $secPwd   = Read-Host "Mot de passe" -AsSecureString
    $password = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto(
                    [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($secPwd))

    if (-not (Validate-NotEmpty $email    "E-mail"))      { Press-Enter; return }
    if (-not (Validate-NotEmpty $password "Mot de passe")) { Press-Enter; return }

    $body     = '{"email":"' + $email + '","password":"' + $password + '"}'
    $response = Invoke-Api -Method POST -Endpoint "/api/v1/auth/login" -Body $body -NoAuth

    try {
        $data  = $response | ConvertFrom-Json
        $token = if ($data.token)            { $data.token }
                 elseif ($data.access_token) { $data.access_token }
                 elseif ($data.data.token)   { $data.data.token }
                 else                        { $null }

        if ($token) {
            $script:AUTH_TOKEN = $token
            Print-Success "Connecté avec succès!"
        } else {
            Print-Error "Echec de la connexion. Reponse:"
            Pretty-Json $response
        }
    } catch {
        Print-Error "Reponse inattendue:"
        Write-Host $response
    }
    Press-Enter
}

function Do-Logout {
    $script:AUTH_TOKEN = ""
    Print-Success "Deconnecte avec succes."
    Press-Enter
}

# ── APPLICATION GROUPS ────────────────────────────────────────────────────────

function List-Groups {
    if (-not (Require-Auth)) { Press-Enter; return }
    Print-Header "GROUPES"
    $response = Api-Get "/api/v1/application-groups"
    try {
        $data = $response | ConvertFrom-Json
        $items = if ($data.data -is [array]) { $data.data } else { @($data.data) }
        foreach ($item in $items) {
            Write-Host "ID   : $($item.id)"
            Write-Host "Nom  : $($item.name)"
            Write-Host "Desc : $($item.description)"
            Write-Host ""
        }
    } catch {
        Pretty-Json $response
    }
    Press-Enter
}

function View-Group {
    if (-not (Require-Auth)) { Press-Enter; return }
    Print-Header "Afficher le groupe"
    $id = Read-Host "ID du groupe"
    if (-not (Validate-Id $id)) { Press-Enter; return }
    Pretty-Json (Api-Get "/api/v1/application-groups/$id")
    Press-Enter
}

function Create-Group {
    if (-not (Require-Auth)) { Press-Enter; return }
    Print-Header "Creer un groupe"
    $name = Read-Host "Nom"
    $desc = Read-Host "Description"
    if (-not (Validate-NotEmpty $name "Nom")) { Press-Enter; return }
    $body = '{"name":"' + $name + '","description":"' + $desc + '"}'
    Pretty-Json (Api-Post "/api/v1/application-groups" $body)
    Press-Enter
}

function Edit-Group {
    if (-not (Require-Auth)) { Press-Enter; return }
    Print-Header "Modifier le groupe"
    $id   = Read-Host "ID du groupe"
    if (-not (Validate-Id $id)) { Press-Enter; return }
    $name = Read-Host "Nouveau nom"
    $desc = Read-Host "Nouvelle description"
    if (-not (Validate-NotEmpty $name "Nom")) { Press-Enter; return }
    $body = '{"name":"' + $name + '","description":"' + $desc + '"}'
    Pretty-Json (Api-Put "/api/v1/application-groups/$id" $body)
    Press-Enter
}

function Delete-Group {
    if (-not (Require-Auth)) { Press-Enter; return }
    Print-Header "Supprimer le groupe"
    $id = Read-Host "ID du groupe a supprimer"
    if (-not (Validate-Id $id))                         { Press-Enter; return }
    if (-not (Confirm-Destructive "Supprimer le groupe $id?")) { Press-Enter; return }
    Pretty-Json (Api-Delete "/api/v1/application-groups/$id")
    Print-Success "Demande de suppression envoyee."
    Press-Enter
}

# ── APPLICATIONS ──────────────────────────────────────────────────────────────

function List-Applications {
    if (-not (Require-Auth)) { Press-Enter; return }
    Print-Header "APPLICATIONS"
    $response = Api-Get "/api/v1/applications"
    try {
        $data = $response | ConvertFrom-Json
        $items = if ($data.data -is [array]) { $data.data } else { @($data.data) }
        foreach ($item in $items) {
            Write-Host "ID   : $($item.id)"
            Write-Host "Nom  : $($item.name)"
            Write-Host "URL  : $($item.url)"
            Write-Host "Desc : $($item.description)"
            Write-Host ""
        }
    } catch {
        Pretty-Json $response
    }
    Press-Enter
}

function View-Application {
    if (-not (Require-Auth)) { Press-Enter; return }
    Print-Header "Afficher l'application"
    $id = Read-Host "ID de l'application"
    if (-not (Validate-Id $id)) { Press-Enter; return }
    Pretty-Json (Api-Get "/api/v1/applications/$id")
    Press-Enter
}

function Create-Application {
    if (-not (Require-Auth)) { Press-Enter; return }
    Print-Header "Creer une application"
    $groupId = Read-Host "ID du groupe d'application"
    if (-not (Validate-Id $groupId)) { Press-Enter; return }
    $name = Read-Host "Nom"
    $url  = Read-Host "URL"
    $desc = Read-Host "Description"
    if (-not (Validate-NotEmpty $name "Nom")) { Press-Enter; return }
    if (-not (Validate-NotEmpty $url  "URL")) { Press-Enter; return }
    $body = '{"name":"' + $name + '","url":"' + $url + '","description":"' + $desc + '","application_group_id":"' + $groupId + '","monitoring_enabled":true}'
    Pretty-Json (Api-Post "/api/v1/applications" $body)
    Press-Enter
}

function Edit-Application {
    if (-not (Require-Auth)) { Press-Enter; return }
    Print-Header "Modifier l'application"
    $id      = Read-Host "ID de l'application"
    if (-not (Validate-Id $id)) { Press-Enter; return }
    $groupId = Read-Host "ID du groupe d'application"
    if (-not (Validate-Id $groupId)) { Press-Enter; return }
    $name = Read-Host "Nom"
    $url  = Read-Host "URL"
    $desc = Read-Host "Description"
    if (-not (Validate-NotEmpty $name "Nom")) { Press-Enter; return }
    $body = '{"name":"' + $name + '","url":"' + $url + '","description":"' + $desc + '","application_group_id":"' + $groupId + '","monitoring_enabled":true}'
    Pretty-Json (Api-Put "/api/v1/applications/$id" $body)
    Press-Enter
}

function Delete-Application {
    if (-not (Require-Auth)) { Press-Enter; return }
    Print-Header "Supprimer l'application"
    $id = Read-Host "ID de l'application a supprimer"
    if (-not (Validate-Id $id))                              { Press-Enter; return }
    if (-not (Confirm-Destructive "Supprimer l'application $id?")) { Press-Enter; return }
    Pretty-Json (Api-Delete "/api/v1/applications/$id")
    Print-Success "Demande de suppression envoyee."
    Press-Enter
}

# ── INCIDENTS ─────────────────────────────────────────────────────────────────

function List-Incidents {
    if (-not (Require-Auth)) { Press-Enter; return }
    Print-Header "INCIDENTS"
    $response = Api-Get "/api/v1/incidents"
    try {
        $data = $response | ConvertFrom-Json
        $items = if ($data.data -is [array]) { $data.data } else { @($data.data) }
        foreach ($item in $items) {
            Write-Host "ID        : $($item.id)"
            Write-Host "Titre     : $($item.title)"
            Write-Host "Statut    : $($item.status)"
            Write-Host "Severite  : $($item.severity)"
            Write-Host "Application : $($item.application.name)"
            Write-Host ""
        }
    } catch {
        Pretty-Json $response
    }
    Press-Enter
}

function View-Incident {
    if (-not (Require-Auth)) { Press-Enter; return }
    Print-Header "Afficher l'incident"
    $id = Read-Host "ID de l'incident"
    if (-not (Validate-Id $id)) { Press-Enter; return }
    Pretty-Json (Api-Get "/api/v1/incidents/$id")
    Press-Enter
}

function Create-Incident {
    if (-not (Require-Auth)) { Press-Enter; return }
    Print-Header "Creer un incident"
    $title = Read-Host "Titre"
    $desc  = Read-Host "Description"
    $appId = Read-Host "ID de l'application"
    if (-not (Validate-NotEmpty $title "Titre"))           { Press-Enter; return }
    if (-not (Validate-NotEmpty $desc  "Description"))     { Press-Enter; return }
    if (-not (Validate-NotEmpty $appId "ID application"))  { Press-Enter; return }

    Write-Host "Selectionner la severite:"
    Write-Host "  1) LOW (Faible)"
    Write-Host "  2) HIGH (Eleve)"
    Write-Host "  3) CRITICAL (Critique)"
    $sc = Read-Host "Choisir (1-3)"
    $severity = switch ($sc) { "1" {"LOW"} "2" {"HIGH"} "3" {"CRITICAL"} default {$null} }
    if (-not $severity) { Print-Error "Choix invalide."; Press-Enter; return }

    $ts   = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
    $body = '{"title":"' + $title + '","description":"' + $desc + '","application_id":"' + $appId + '","severity":"' + $severity + '","status":"OPEN","started_at":"' + $ts + '"}'
    Pretty-Json (Api-Post "/api/v1/incidents" $body)
    Press-Enter
}

function Edit-Incident {
    if (-not (Require-Auth)) { Press-Enter; return }
    Print-Header "Modifier l'incident"
    $id    = Read-Host "ID de l'incident"
    if (-not (Validate-Id $id)) { Press-Enter; return }
    $title = Read-Host "Titre"
    $desc  = Read-Host "Description"
    if (-not (Validate-NotEmpty $title "Titre")) { Press-Enter; return }

    Write-Host "Selectionner le statut:"
    Write-Host "  1) OPEN (Ouvert)"
    Write-Host "  2) IN_PROGRESS (En cours)"
    Write-Host "  3) RESOLVED (Resolu)"
    Write-Host "  4) CLOSED (Ferme)"
    $stc = Read-Host "Choisir (1-4)"
    $status = switch ($stc) { "1" {"OPEN"} "2" {"IN_PROGRESS"} "3" {"RESOLVED"} "4" {"CLOSED"} default {$null} }
    if (-not $status) { Print-Error "Choix invalide."; Press-Enter; return }

    Write-Host "Selectionner la severite:"
    Write-Host "  1) LOW (Faible)"
    Write-Host "  2) HIGH (Eleve)"
    Write-Host "  3) CRITICAL (Critique)"
    $sc = Read-Host "Choisir (1-3)"
    $severity = switch ($sc) { "1" {"LOW"} "2" {"HIGH"} "3" {"CRITICAL"} default {$null} }
    if (-not $severity) { Print-Error "Choix invalide."; Press-Enter; return }

    $body = '{"title":"' + $title + '","description":"' + $desc + '","status":"' + $status + '","severity":"' + $severity + '"}'
    $response = Api-Put "/api/v1/incidents/$id" $body
    Pretty-Json $response
    try {
        if (($response | ConvertFrom-Json).success) { Print-Success "Incident modifie avec succes." }
        else { Print-Error "La modification a echoue." }
    } catch {}
    Press-Enter
}

function Delete-Incident {
    if (-not (Require-Auth)) { Press-Enter; return }
    Print-Header "Supprimer l'incident"
    $id = Read-Host "ID de l'incident a supprimer"
    if (-not (Validate-Id $id))                              { Press-Enter; return }
    if (-not (Confirm-Destructive "Supprimer l'incident $id?")) { Press-Enter; return }
    Pretty-Json (Api-Delete "/api/v1/incidents/$id")
    Print-Success "Demande de suppression envoyee."
    Press-Enter
}

function Resolve-Incident {
    if (-not (Require-Auth)) { Press-Enter; return }
    Print-Header "Resoudre l'incident"
    $id = Read-Host "ID de l'incident a resoudre"
    if (-not (Validate-Id $id))                               { Press-Enter; return }
    if (-not (Confirm-Destructive "Resoudre l'incident $id?")) { Press-Enter; return }

    # Fetch current data so we preserve title/description/severity
    Print-Info "Recuperation des donnees de l'incident..."
    $current = Api-Get "/api/v1/incidents/$id"
    try {
        $data = $current | ConvertFrom-Json
        # Support both flat and nested { data: {...} } shapes
        $obj  = if ($data.data) { $data.data } else { $data }
        $title    = $obj.title
        $desc     = $obj.description
        $severity = $obj.severity
        if ([string]::IsNullOrEmpty($title)) { throw "empty" }
    } catch {
        Print-Error "Impossible de recuperer l'incident. Verifiez l'ID."
        Press-Enter; return
    }

    $body     = '{"title":"' + $title + '","description":"' + $desc + '","status":"RESOLVED","severity":"' + $severity + '"}'
    $response = Api-Put "/api/v1/incidents/$id" $body
    Pretty-Json $response
    try {
        if (($response | ConvertFrom-Json).success) { Print-Success "Incident resolu avec succes." }
        else { Print-Error "La resolution a echoue. Voir la reponse ci-dessus." }
    } catch {}
    Press-Enter
}

# ── SUBMENUS ──────────────────────────────────────────────────────────────────

# Removed - operations now in main menu

# ── MAIN MENU ─────────────────────────────────────────────────────────────────

function Main-Menu {
    while ($true) {
        Clear-Host
        Write-Host "========================================" -ForegroundColor Blue
        Write-Host "   Tableau de bord CLI MonitoringApp" -ForegroundColor Blue
        Write-Host "========================================" -ForegroundColor Blue
        Write-Host ""
        if (-not [string]::IsNullOrEmpty($script:AUTH_TOKEN)) {
            Write-Host "  Statut: " -NoNewline; Write-Host "Connecte" -ForegroundColor Green
        } else {
            Write-Host "  Statut: " -NoNewline; Write-Host "Non connecte" -ForegroundColor Red
        }
        Write-Host ""
        Write-Host "  1) Connexion"
        Write-Host ""
        Write-Host "------- GROUPES -------"
        Write-Host "  2) Liste groupes"
        Write-Host "  3) Voir groupe"
        Write-Host "  4) Creer groupe"
        Write-Host "  5) Modifier groupe"
        Write-Host "  6) Supprimer groupe"
        Write-Host ""
        Write-Host "------- APPLICATIONS -------"
        Write-Host "  7) Liste applications"
        Write-Host "  8) Voir application"
        Write-Host "  9) Creer application"
        Write-Host "  10) Modifier application"
        Write-Host "  11) Supprimer application"
        Write-Host ""
        Write-Host "------- INCIDENTS -------"
        Write-Host "  12) Liste incidents"
        Write-Host "  13) Voir incident"
        Write-Host "  14) Creer incident"
        Write-Host "  15) Modifier incident"
        Write-Host "  16) Supprimer incident"
        Write-Host "  17) Resoudre incident"
        Write-Host ""
        Write-Host "  0) Quitter"
        Write-Host ""
        $c = Read-Host "Choisir"
        switch ($c) {
            "1"  { Clear-Host; Do-Login }
            "2"  { Clear-Host; List-Groups }
            "3"  { Clear-Host; View-Group }
            "4"  { Clear-Host; Create-Group }
            "5"  { Clear-Host; Edit-Group }
            "6"  { Clear-Host; Delete-Group }
            "7"  { Clear-Host; List-Applications }
            "8"  { Clear-Host; View-Application }
            "9"  { Clear-Host; Create-Application }
            "10" { Clear-Host; Edit-Application }
            "11" { Clear-Host; Delete-Application }
            "12" { Clear-Host; List-Incidents }
            "13" { Clear-Host; View-Incident }
            "14" { Clear-Host; Create-Incident }
            "15" { Clear-Host; Edit-Incident }
            "16" { Clear-Host; Delete-Incident }
            "17" { Clear-Host; Resolve-Incident }
            "0"  { Write-Host "Au revoir!" -ForegroundColor Green; exit 0 }
            default { Print-Warn "Option invalide. Choisir 0-17."; Start-Sleep -Seconds 1 }
        }
    }
}

Main-Menu
