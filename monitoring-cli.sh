#!/usr/bin/env bash
# monitoring-cli.sh - Interactive CLI for MonitoringApp API

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/config.sh"

# ─────────────────────────────────────────
# AUTH FUNCTIONS
# ─────────────────────────────────────────

do_login() {
    print_header "Connexion"
    read -rp "E-mail: " email
    read -rsp "Mot de passe: " password; echo

    validate_not_empty "$email" "E-mail" || return 1
    validate_not_empty "$password" "Mot de passe" || return 1

    local response
    response=$(curl -s -X POST "$BASE_URL/api/v1/auth/login" \
        -H "Content-Type: application/json" \
        -d "{\"email\":\"$email\",\"password\":\"$password\"}")

    # Extract token - try common field names
    local token
    token=$(echo "$response" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('token') or d.get('access_token') or d.get('data',{}).get('token',''))" 2>/dev/null)

    if [ -n "$token" ]; then
        AUTH_TOKEN="$token"
        print_success "Connecté avec succès!"
    else
        print_error "Échec de la connexion. Réponse:"
        pretty_json "$response"
    fi
    press_enter
}

do_logout() {
    AUTH_TOKEN=""
    print_success "Déconnecté avec succès."
    press_enter
}

# ─────────────────────────────────────────
# APPLICATION GROUPS FUNCTIONS
# ─────────────────────────────────────────

list_groups() {
    require_auth || return
    print_header "Groupes d'applications"
    local response
    response=$(api_get "/api/v1/application-groups")
    pretty_json "$response"
    press_enter
}

view_group() {
    require_auth || return
    print_header "Afficher le groupe d'application"
    read -rp "ID du groupe: " id
    validate_id "$id" || return 1
    local response
    response=$(api_get "/api/v1/application-groups/$id")
    pretty_json "$response"
    press_enter
}

create_group() {
    require_auth || return
    print_header "Créer un groupe d'application"
    read -rp "Nom: " name
    read -rp "Description: " description
    validate_not_empty "$name" "Nom" || return 1
    local data="{\"name\":\"$name\",\"description\":\"$description\"}"
    local response
    response=$(api_post "/api/v1/application-groups" "$data")
    pretty_json "$response"
    press_enter
}

edit_group() {
    require_auth || return
    print_header "Modifier le groupe d'application"
    read -rp "ID du groupe: " id
    validate_id "$id" || return 1
    read -rp "Nouveau nom: " name
    read -rp "Nouvelle description: " description
    validate_not_empty "$name" "Nom" || return 1
    local data="{\"name\":\"$name\",\"description\":\"$description\"}"
    local response
    response=$(api_put "/api/v1/application-groups/$id" "$data")
    pretty_json "$response"
    press_enter
}

delete_group() {
    require_auth || return
    print_header "Supprimer le groupe d'application"
    read -rp "ID du groupe à supprimer: " id
    validate_id "$id" || return 1
    confirm_action "Supprimer le groupe $id?" || return
    local response
    response=$(api_delete "/api/v1/application-groups/$id")
    pretty_json "$response"
    print_success "Demande de suppression envoyée."
    press_enter
}

# ─────────────────────────────────────────
# APPLICATIONS FUNCTIONS
# ─────────────────────────────────────────

list_applications() {
    require_auth || return
    print_header "Applications"
    local response
    response=$(api_get "/api/v1/applications")
    pretty_json "$response"
    press_enter
}

view_application() {
    require_auth || return
    print_header "Afficher l'application"
    read -rp "ID de l'application: " id
    validate_id "$id" || return 1
    local response
    response=$(api_get "/api/v1/applications/$id")
    pretty_json "$response"
    press_enter
}

create_application() {
    require_auth || return
    print_header "Créer une application"
    read -rp "ID du groupe d'application: " group_id
    validate_id "$group_id" || return 1
    read -rp "Nom: " name
    read -rp "URL: " url
    read -rp "Description: " description
    validate_not_empty "$name" "Nom" || return 1
    validate_not_empty "$url" "URL" || return 1
    local data="{\"name\":\"$name\",\"url\":\"$url\",\"description\":\"$description\",\"application_group_id\":\"$group_id\",\"monitoring_enabled\":true}"
    local response
    response=$(api_post "/api/v1/applications" "$data")
    pretty_json "$response"
    press_enter
}

edit_application() {
    require_auth || return
    print_header "Modifier l'application"
    read -rp "ID de l'application: " id
    validate_id "$id" || return 1
    read -rp "ID du groupe d'application: " group_id
    validate_id "$group_id" || return 1
    read -rp "Nom: " name
    read -rp "URL: " url
    read -rp "Description: " description
    validate_not_empty "$name" "Nom" || return 1
    local data="{\"name\":\"$name\",\"url\":\"$url\",\"description\":\"$description\",\"application_group_id\":\"$group_id\",\"monitoring_enabled\":true}"
    local response
    response=$(api_put "/api/v1/applications/$id" "$data")
    pretty_json "$response"
    press_enter
}

delete_application() {
    require_auth || return
    print_header "Supprimer l'application"
    read -rp "ID de l'application à supprimer: " id
    validate_id "$id" || return 1
    confirm_action "Supprimer l'application $id?" || return
    local response
    response=$(api_delete "/api/v1/applications/$id")
    pretty_json "$response"
    print_success "Demande de suppression envoyée."
    press_enter
}

# ─────────────────────────────────────────
# INCIDENTS FUNCTIONS
# ─────────────────────────────────────────

list_incidents() {
    require_auth || return
    print_header "Incidents"
    local response
    response=$(api_get "/api/v1/incidents")
    pretty_json "$response"
    press_enter
}

view_incident() {
    require_auth || return
    print_header "Afficher l'incident"
    read -rp "ID de l'incident: " id
    validate_id "$id" || return 1
    local response
    response=$(api_get "/api/v1/incidents/$id")
    pretty_json "$response"
    press_enter
}

create_incident() {
    require_auth || return
    print_header "Créer un incident"
    read -rp "Titre: " title
    read -rp "Description: " description
    read -rp "ID de l'application: " app_id
    
    # Severity selection menu
    echo "Sélectionner la sévérité:"
    echo "  1) LOW (Faible)"
    #echo "  2) MEDIUM (Moyen)"
    echo "  2) HIGH (Élevé)"
    echo "  3) CRITICAL (Critique)"
    read -rp "Choisir (1-3): " severity_choice
    
    local severity
    case "$severity_choice" in
        1) severity="LOW" ;;
        #2) severity="MEDIUM" ;;
        2) severity="HIGH" ;;
        3) severity="CRITICAL" ;;
        *) print_error "Choix invalide"; return 1 ;;
    esac
    
    validate_not_empty "$title" "Titre" || return 1
    validate_not_empty "$description" "Description" || return 1
    validate_not_empty "$app_id" "ID de l'application" || return 1
    # Get current ISO 8601 timestamp
    local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ" 2>/dev/null || echo "")
    # Fallback for systems without date command
    [ -z "$timestamp" ] && timestamp=$(TZ=UTC python3 -c "from datetime import datetime; print(datetime.utcnow().isoformat() + 'Z')" 2>/dev/null || echo "")
    local data="{\"title\":\"$title\",\"description\":\"$description\",\"application_id\":\"$app_id\",\"severity\":\"$severity\",\"status\":\"OPEN\",\"started_at\":\"$timestamp\"}"
    local response
    response=$(api_post "/api/v1/incidents" "$data")
    pretty_json "$response"
    press_enter
}

edit_incident() {
    require_auth || return
    print_header "Modifier l'incident"
    read -rp "ID de l'incident: " id
    validate_id "$id" || return 1
    read -rp "Titre: " title
    read -rp "Description: " description
    
    # Status selection menu
    echo "Sélectionner le statut:"
    echo "  1) OPEN (Ouvert)"
    echo "  2) IN_PROGRESS (En cours)"
    echo "  3) RESOLVED (Résolu)"
    echo "  4) CLOSED (Fermé)"
    read -rp "Choisir (1-4): " status_choice
    
    local status
    case "$status_choice" in
        1) status="OPEN" ;;
        2) status="IN_PROGRESS" ;;
        3) status="RESOLVED" ;;
        4) status="CLOSED" ;;
        *) print_error "Choix invalide"; return 1 ;;
    esac
    
    # Severity selection menu
    echo "Sélectionner la sévérité:"
    echo "  1) LOW (Faible)"
    echo "  2) HIGH (Élevé)"
    echo "  3) CRITICAL (Critique)"
    read -rp "Choisir (1-3): " severity_choice
    
    local severity
    case "$severity_choice" in
        1) severity="LOW" ;;
        2) severity="HIGH" ;;
        3) severity="CRITICAL" ;;
        *) print_error "Choix invalide"; return 1 ;;
    esac

    local data="{\"title\":\"$title\",\"description\":\"$description\",\"status\":\"$status\",\"severity\":\"$severity\"}"
    local response
    response=$(api_put "/api/v1/incidents/$id" "$data")
    pretty_json "$response"
    press_enter
}

delete_incident() {
    require_auth || return
    print_header "Supprimer l'incident"
    read -rp "ID de l'incident à supprimer: " id
    validate_id "$id" || return 1
    confirm_action "Supprimer l'incident $id?" || return
    local response
    response=$(api_delete "/api/v1/incidents/$id")
    pretty_json "$response"
    print_success "Demande de suppression envoyée."
    press_enter
}

resolve_incident() {
    require_auth || return
    print_header "Résoudre l'incident"
    read -rp "ID de l'incident à résoudre: " id
    validate_id "$id" || return 1
    confirm_action "Résoudre l'incident $id?" || return

    # Fetch current incident so we can preserve title/description/severity
    print_info "Récupération des données de l'incident..."
    local current
    current=$(api_get "/api/v1/incidents/$id")

    local title description severity
    title=$(echo "$current"       | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('data',d).get('title',''))"       2>/dev/null)
    description=$(echo "$current" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('data',d).get('description',''))" 2>/dev/null)
    severity=$(echo "$current"    | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('data',d).get('severity','LOW'))"  2>/dev/null)

    if [ -z "$title" ]; then
        print_error "Impossible de récupérer l'incident. Vérifiez l'ID."
        press_enter
        return 1
    fi

    local data="{\"title\":\"$title\",\"description\":\"$description\",\"status\":\"RESOLVED\",\"severity\":\"$severity\"}"
    local response
    response=$(api_put "/api/v1/incidents/$id" "$data")
    pretty_json "$response"

    if echo "$response" | python3 -c "import sys,json; d=json.load(sys.stdin); exit(0 if d.get('success') else 1)" 2>/dev/null; then
        print_success "Incident résolu avec succès."
    else
        print_error "La résolution a échoué. Voir la réponse ci-dessus."
    fi
    press_enter
}

# ─────────────────────────────────────────
# MENUS
# ─────────────────────────────────────────

menu_groups() {
    while true; do
        clear
        print_header "Gérer les groupes d'applications"
        echo "  1) Lister tous les groupes"
        echo "  2) Afficher le groupe par ID"
        echo "  3) Créer un nouveau groupe"
        echo "  4) Modifier le groupe"
        echo "  5) Supprimer le groupe"
        echo "  0) Retour au menu principal"
        echo ""
        read -rp "Choisir: " choice
        case "$choice" in
            1) clear; list_groups ;;
            2) clear; view_group ;;
            3) clear; create_group ;;
            4) clear; edit_group ;;
            5) clear; delete_group ;;
            0) return ;;
            *) print_warn "Option invalide" ; sleep 1 ;;
        esac
    done
}

menu_applications() {
    while true; do
        clear
        print_header "Gérer les applications"
        echo "  1) Lister toutes les applications"
        echo "  2) Afficher l'application par ID"
        echo "  3) Créer une nouvelle application"
        echo "  4) Modifier l'application"
        echo "  5) Supprimer l'application"
        echo "  0) Retour au menu principal"
        echo ""
        read -rp "Choisir: " choice
        case "$choice" in
            1) clear; list_applications ;;
            2) clear; view_application ;;
            3) clear; create_application ;;
            4) clear; edit_application ;;
            5) clear; delete_application ;;
            0) return ;;
            *) print_warn "Option invalide" ; sleep 1 ;;
        esac
    done
}

menu_incidents() {
    while true; do
        clear
        print_header "Gérer les incidents"
        echo "  1) Lister tous les incidents"
        echo "  2) Afficher l'incident par ID"
        echo "  3) Créer un nouvel incident"
        echo "  4) Modifier l'incident"
        echo "  5) Supprimer l'incident"
        echo "  6) Résoudre l'incident"
        echo "  0) Retour au menu principal"
        echo ""
        read -rp "Choisir: " choice
        case "$choice" in
            1) clear; list_incidents ;;
            2) clear; view_incident ;;
            3) clear; create_incident ;;
            4) clear; edit_incident ;;
            5) clear; delete_incident ;;
            6) clear; resolve_incident ;;
            0) return ;;
            *) print_warn "Option invalide" ; sleep 1 ;;
        esac
    done
}

main_menu() {
    trap 'echo -e "\n${YELLOW}Sortie...${NC}"; exit 0' INT
    while true; do
        clear
        echo -e "${BOLD}${BLUE}"
        echo "╔══════════════════════════════════════╗"
        echo "║     Tableau de bord CLI MonitoringApp ║"
        echo "╚══════════════════════════════════════╝"
        echo -e "${NC}"
        if [ -n "$AUTH_TOKEN" ]; then
            echo -e "  Statut: ${GREEN}● Connecté${NC}"
        else
            echo -e "  Statut: ${RED}● Non connecté${NC}"
        fi
        echo ""
        echo "  1) Connexion"
        echo "  2) Gérer les groupes"
        echo "  3) Gérer les applications"
        echo "  4) Gérer les incidents"
        echo "  5) Déconnexion"
        echo "  6) Quitter"
        echo ""
        read -rp "Choisissez une option: " choice
        case "$choice" in
            1) clear; do_login ;;
            2) menu_groups ;;
            3) menu_applications ;;
            4) menu_incidents ;;
            5) clear; do_logout ;;
            6) echo -e "${GREEN}Au revoir!${NC}"; exit 0 ;;
            *) print_warn "Option invalide. Veuillez choisir 1-6."; sleep 1 ;;
        esac
    done
}

main_menu
