#!/usr/bin/env bash
# monitoring-cli.sh - Interactive CLI for MonitoringApp API

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/config.sh"

# ─────────────────────────────────────────
# AUTH FUNCTIONS
# ─────────────────────────────────────────

do_login() {
    print_header "Login"
    read -rp "Email: " email
    read -rsp "Password: " password; echo

    validate_not_empty "$email" "Email" || return 1
    validate_not_empty "$password" "Password" || return 1

    local response
    response=$(curl -s -X POST "$BASE_URL/api/v1/auth/login" \
        -H "Content-Type: application/json" \
        -d "{\"email\":\"$email\",\"password\":\"$password\"}")

    # Extract token - try common field names
    local token
    token=$(echo "$response" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('token') or d.get('access_token') or d.get('data',{}).get('token',''))" 2>/dev/null)

    if [ -n "$token" ]; then
        AUTH_TOKEN="$token"
        print_success "Logged in successfully!"
    else
        print_error "Login failed. Response:"
        pretty_json "$response"
    fi
    press_enter
}

do_logout() {
    AUTH_TOKEN=""
    print_success "Logged out successfully."
    press_enter
}

# ─────────────────────────────────────────
# APPLICATION GROUPS FUNCTIONS
# ─────────────────────────────────────────

list_groups() {
    require_auth || return
    print_header "Application Groups"
    local response
    response=$(api_get "/api/v1/application-groups")
    pretty_json "$response"
    press_enter
}

view_group() {
    require_auth || return
    print_header "View Application Group"
    read -rp "Group ID: " id
    validate_id "$id" || return 1
    local response
    response=$(api_get "/api/v1/application-groups/$id")
    pretty_json "$response"
    press_enter
}

create_group() {
    require_auth || return
    print_header "Create Application Group"
    read -rp "Name: " name
    read -rp "Description: " description
    validate_not_empty "$name" "Name" || return 1
    local data="{\"name\":\"$name\",\"description\":\"$description\"}"
    local response
    response=$(api_post "/api/v1/application-groups" "$data")
    pretty_json "$response"
    press_enter
}

edit_group() {
    require_auth || return
    print_header "Edit Application Group"
    read -rp "Group ID: " id
    validate_id "$id" || return 1
    read -rp "New Name: " name
    read -rp "New Description: " description
    validate_not_empty "$name" "Name" || return 1
    local data="{\"name\":\"$name\",\"description\":\"$description\"}"
    local response
    response=$(api_put "/api/v1/application-groups/$id" "$data")
    pretty_json "$response"
    press_enter
}

delete_group() {
    require_auth || return
    print_header "Delete Application Group"
    read -rp "Group ID to delete: " id
    validate_id "$id" || return 1
    confirm_action "Delete group $id?" || return
    local response
    response=$(api_delete "/api/v1/application-groups/$id")
    pretty_json "$response"
    print_success "Delete request sent."
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
    print_header "View Application"
    read -rp "Application ID: " id
    validate_id "$id" || return 1
    local response
    response=$(api_get "/api/v1/applications/$id")
    pretty_json "$response"
    press_enter
}

create_application() {
    require_auth || return
    print_header "Create Application"
    read -rp "Name: " name
    read -rp "URL: " url
    read -rp "Description: " description
    validate_not_empty "$name" "Name" || return 1
    validate_not_empty "$url" "URL" || return 1
    local data="{\"name\":\"$name\",\"url\":\"$url\",\"description\":\"$description\"}"
    local response
    response=$(api_post "/api/v1/applications" "$data")
    pretty_json "$response"
    press_enter
}

edit_application() {
    require_auth || return
    print_header "Edit Application"
    read -rp "Application ID: " id
    validate_id "$id" || return 1
    read -rp "Name: " name
    read -rp "URL: " url
    read -rp "Description: " description
    validate_not_empty "$name" "Name" || return 1
    local data="{\"name\":\"$name\",\"url\":\"$url\",\"description\":\"$description\"}"
    local response
    response=$(api_put "/api/v1/applications/$id" "$data")
    pretty_json "$response"
    press_enter
}

delete_application() {
    require_auth || return
    print_header "Delete Application"
    read -rp "Application ID to delete: " id
    validate_id "$id" || return 1
    confirm_action "Delete application $id?" || return
    local response
    response=$(api_delete "/api/v1/applications/$id")
    pretty_json "$response"
    print_success "Delete request sent."
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
    print_header "View Incident"
    read -rp "Incident ID: " id
    validate_id "$id" || return 1
    local response
    response=$(api_get "/api/v1/incidents/$id")
    pretty_json "$response"
    press_enter
}

create_incident() {
    require_auth || return
    print_header "Create Incident"
    read -rp "Title: " title
    read -rp "Description: " description
    read -rp "Application ID: " app_id
    read -rp "Severity (low/medium/high/critical): " severity
    validate_not_empty "$title" "Title" || return 1
    validate_not_empty "$app_id" "Application ID" || return 1
    local data="{\"title\":\"$title\",\"description\":\"$description\",\"application_id\":$app_id,\"severity\":\"$severity\"}"
    local response
    response=$(api_post "/api/v1/incidents" "$data")
    pretty_json "$response"
    press_enter
}

edit_incident() {
    require_auth || return
    print_header "Edit Incident"
    read -rp "Incident ID: " id
    validate_id "$id" || return 1
    read -rp "Title: " title
    read -rp "Description: " description
    read -rp "Status (open/investigating/resolved): " status
    read -rp "Severity (low/medium/high/critical): " severity
    validate_not_empty "$title" "Title" || return 1
    local data="{\"title\":\"$title\",\"description\":\"$description\",\"status\":\"$status\",\"severity\":\"$severity\"}"
    local response
    response=$(api_put "/api/v1/incidents/$id" "$data")
    pretty_json "$response"
    press_enter
}

delete_incident() {
    require_auth || return
    print_header "Delete Incident"
    read -rp "Incident ID to delete: " id
    validate_id "$id" || return 1
    confirm_action "Delete incident $id?" || return
    local response
    response=$(api_delete "/api/v1/incidents/$id")
    pretty_json "$response"
    print_success "Delete request sent."
    press_enter
}

resolve_incident() {
    require_auth || return
    print_header "Resolve Incident"
    read -rp "Incident ID to resolve: " id
    validate_id "$id" || return 1
    confirm_action "Resolve incident $id?" || return
    local response
    response=$(api_put "/api/v1/incidents/$id/resolve" "{}")
    pretty_json "$response"
    print_success "Resolve request sent."
    press_enter
}

# ─────────────────────────────────────────
# MENUS
# ─────────────────────────────────────────

menu_groups() {
    while true; do
        clear
        print_header "Manage Application Groups"
        echo "  1) List all groups"
        echo "  2) View group by ID"
        echo "  3) Create new group"
        echo "  4) Edit group"
        echo "  5) Delete group"
        echo "  0) Back to main menu"
        echo ""
        read -rp "Choose: " choice
        case "$choice" in
            1) clear; list_groups ;;
            2) clear; view_group ;;
            3) clear; create_group ;;
            4) clear; edit_group ;;
            5) clear; delete_group ;;
            0) return ;;
            *) print_warn "Invalid option" ; sleep 1 ;;
        esac
    done
}

menu_applications() {
    while true; do
        clear
        print_header "Manage Applications"
        echo "  1) List all applications"
        echo "  2) View application by ID"
        echo "  3) Create new application"
        echo "  4) Edit application"
        echo "  5) Delete application"
        echo "  0) Back to main menu"
        echo ""
        read -rp "Choose: " choice
        case "$choice" in
            1) clear; list_applications ;;
            2) clear; view_application ;;
            3) clear; create_application ;;
            4) clear; edit_application ;;
            5) clear; delete_application ;;
            0) return ;;
            *) print_warn "Invalid option" ; sleep 1 ;;
        esac
    done
}

menu_incidents() {
    while true; do
        clear
        print_header "Manage Incidents"
        echo "  1) List all incidents"
        echo "  2) View incident by ID"
        echo "  3) Create new incident"
        echo "  4) Edit incident"
        echo "  5) Delete incident"
        echo "  6) Resolve incident"
        echo "  0) Back to main menu"
        echo ""
        read -rp "Choose: " choice
        case "$choice" in
            1) clear; list_incidents ;;
            2) clear; view_incident ;;
            3) clear; create_incident ;;
            4) clear; edit_incident ;;
            5) clear; delete_incident ;;
            6) clear; resolve_incident ;;
            0) return ;;
            *) print_warn "Invalid option" ; sleep 1 ;;
        esac
    done
}

main_menu() {
    trap 'echo -e "\n${YELLOW}Exiting...${NC}"; exit 0' INT
    while true; do
        clear
        echo -e "${BOLD}${BLUE}"
        echo "╔══════════════════════════════════════╗"
        echo "║      MonitoringApp CLI Dashboard      ║"
        echo "╚══════════════════════════════════════╝"
        echo -e "${NC}"
        if [ -n "$AUTH_TOKEN" ]; then
            echo -e "  Status: ${GREEN}● Logged In${NC}"
        else
            echo -e "  Status: ${RED}● Not Logged In${NC}"
        fi
        echo ""
        echo "  1) Login"
        echo "  2) Manage Groups"
        echo "  3) Manage Applications"
        echo "  4) Manage Incidents"
        echo "  5) Logout"
        echo "  6) Exit"
        echo ""
        read -rp "Choose an option: " choice
        case "$choice" in
            1) clear; do_login ;;
            2) menu_groups ;;
            3) menu_applications ;;
            4) menu_incidents ;;
            5) clear; do_logout ;;
            6) echo -e "${GREEN}Goodbye!${NC}"; exit 0 ;;
            *) print_warn "Invalid option. Please choose 1-6."; sleep 1 ;;
        esac
    done
}

main_menu
