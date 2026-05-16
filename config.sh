#!/usr/bin/env bash
# Color constants
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# API base URL
BASE_URL="https://monitoring-app.on-forge.com"

# Session token (set after login)
AUTH_TOKEN=""

# Helper: print colored output
print_success() { echo -e "${GREEN}[SUCCÈS]${NC} $1"; }
print_error()   { echo -e "${RED}[ERREUR]${NC} $1"; }
print_warn()    { echo -e "${YELLOW}[AVERTISSEMENT]${NC} $1"; }
print_info()    { echo -e "${CYAN}[INFO]${NC} $1"; }
print_header()  { echo -e "\n${BOLD}${BLUE}=== $1 ===${NC}\n"; }

# Helper: check if token is set
require_auth() {
    if [ -z "$AUTH_TOKEN" ]; then
        print_error "Non connecté. Veuillez vous connecter d'abord (option 1)."
        return 1
    fi
    return 0
}

# Helper: make authenticated GET request
api_get() {
    local endpoint="$1"
    curl -s -X GET "$BASE_URL$endpoint" \
        -H "Authorization: Bearer $AUTH_TOKEN" \
        -H "Content-Type: application/json"
}

# Helper: make authenticated POST request
api_post() {
    local endpoint="$1"
    local data="$2"
    curl -s -X POST "$BASE_URL$endpoint" \
        -H "Authorization: Bearer $AUTH_TOKEN" \
        -H "Content-Type: application/json" \
        -d "$data"
}

# Helper: make authenticated PUT request
api_put() {
    local endpoint="$1"
    local data="$2"
    curl -s -X PUT "$BASE_URL$endpoint" \
        -H "Authorization: Bearer $AUTH_TOKEN" \
        -H "Content-Type: application/json" \
        -d "$data"
}

# Helper: make authenticated DELETE request
api_delete() {
    local endpoint="$1"
    curl -s -X DELETE "$BASE_URL$endpoint" \
        -H "Authorization: Bearer $AUTH_TOKEN" \
        -H "Content-Type: application/json"
}

# Helper: pretty-print JSON (uses python3 or python fallback)
pretty_json() {
    if command -v python3 &>/dev/null; then
        echo "$1" | python3 -m json.tool 2>/dev/null || echo "$1"
    elif command -v python &>/dev/null; then
        echo "$1" | python -m json.tool 2>/dev/null || echo "$1"
    else
        echo "$1"
    fi
}

# Helper: validate non-empty input
validate_not_empty() {
    local value="$1"
    local field="$2"
    if [ -z "$value" ]; then
        print_error "$field ne peut pas être vide."
        return 1
    fi
    return 0
}

# Helper: validate numeric ID
validate_id() {
    local id="$1"
    if ! [[ "$id" =~ ^[0-9]+$ ]]; then
        print_error "L'ID doit être un nombre."
        return 1
    fi
    return 0
}

# Helper: confirm destructive action
confirm_action() {
    local message="${1:-Êtes-vous sûr(e)?}"
    echo -e "${YELLOW}$message (o/n): ${NC}\c"
    read -r answer
    case "$answer" in
        [Oo]|[Oo][Uu][Ii]) return 0 ;;
        *) print_warn "Opération annulée."; return 1 ;;
    esac
}

# Helper: press any key to continue
press_enter() {
    echo -e "\n${CYAN}Appuyez sur Entrée pour continuer...${NC}"
    read -r
}

# Helper: check HTTP status from response
check_response() {
    local response="$1"
    # Try to extract common error fields
    if echo "$response" | grep -q '"error"'; then
        print_error "L'API a renvoyé une erreur:"
        pretty_json "$response"
        return 1
    fi
    return 0
}
