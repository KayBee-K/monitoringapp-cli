# MonitoringApp CLI

A fully interactive, menu-driven Bash CLI for the **MonitoringApp REST API**. Manage application groups, applications, and incidents entirely from your terminal.

---

## Project Description

MonitoringApp CLI provides a user-friendly terminal interface to interact with the MonitoringApp platform hosted at `https://monitoring-app.on-forge.com`. Instead of crafting raw `curl` commands, this tool presents hierarchical menus that guide you through authentication and all CRUD operations across three resource types:

- **Application Groups** — logical groupings of applications
- **Applications** — individual monitored services or endpoints
- **Incidents** — events or outages associated with applications

The CLI maintains your session token in memory for the duration of the session. No credentials are ever written to disk.

---

## Prerequisites

| Requirement | Version | Notes |
|-------------|---------|-------|
| Bash | 4.0+ | Required for `read -r`, arrays, and `[[ ]]` |
| curl | Any recent | Used for all HTTP requests |
| python3 | 3.x (optional) | Used for pretty JSON formatting; falls back to raw output |

### Checking Prerequisites

```bash
bash --version
curl --version
python3 --version
```

---

## Setup Instructions

### 1. Clone or Download

```bash
git clone <repo-url> monitoringapp-cli
cd monitoringapp-cli
```

### 2. Make the Main Script Executable

```bash
chmod +x monitoring-cli.sh
```

> `config.sh` does not need to be executable — it is sourced by `monitoring-cli.sh`.

### 3. Run the CLI

```bash
./monitoring-cli.sh
```

Or via bash explicitly:

```bash
bash monitoring-cli.sh
```

---

## Menu Walkthrough

When you launch the CLI, you will see the **Main Dashboard**:

```
╔══════════════════════════════════════╗
║      MonitoringApp CLI Dashboard      ║
╚══════════════════════════════════════╝

  Status: ● Not Logged In

  1) Login
  2) Manage Groups
  3) Manage Applications
  4) Manage Incidents
  5) Logout
  6) Exit
```

### Main Menu Options

| Option | Description |
|--------|-------------|
| 1 | Authenticate with the API using email and password |
| 2 | Enter the Application Groups submenu |
| 3 | Enter the Applications submenu |
| 4 | Enter the Incidents submenu |
| 5 | Clear the session token (logout) |
| 6 | Exit the program |

---

### Submenu: Manage Application Groups (17 total operations — 5 here)

```
  1) List all groups
  2) View group by ID
  3) Create new group
  4) Edit group
  5) Delete group
  0) Back to main menu
```

| # | Operation | HTTP Method | Endpoint |
|---|-----------|-------------|----------|
| 1 | List all groups | GET | `/api/v1/application-groups` |
| 2 | View group by ID | GET | `/api/v1/application-groups/{id}` |
| 3 | Create new group | POST | `/api/v1/application-groups` |
| 4 | Edit group | PUT | `/api/v1/application-groups/{id}` |
| 5 | Delete group | DELETE | `/api/v1/application-groups/{id}` |

---

### Submenu: Manage Applications (5 operations)

```
  1) List all applications
  2) View application by ID
  3) Create new application
  4) Edit application
  5) Delete application
  0) Back to main menu
```

| # | Operation | HTTP Method | Endpoint |
|---|-----------|-------------|----------|
| 1 | List all applications | GET | `/api/v1/applications` |
| 2 | View application by ID | GET | `/api/v1/applications/{id}` |
| 3 | Create new application | POST | `/api/v1/applications` |
| 4 | Edit application | PUT | `/api/v1/applications/{id}` |
| 5 | Delete application | DELETE | `/api/v1/applications/{id}` |

---

### Submenu: Manage Incidents (6 operations + login/logout = 17 total)

```
  1) List all incidents
  2) View incident by ID
  3) Create new incident
  4) Edit incident
  5) Delete incident
  6) Resolve incident
  0) Back to main menu
```

| # | Operation | HTTP Method | Endpoint |
|---|-----------|-------------|----------|
| 1 | List all incidents | GET | `/api/v1/incidents` |
| 2 | View incident by ID | GET | `/api/v1/incidents/{id}` |
| 3 | Create new incident | POST | `/api/v1/incidents` |
| 4 | Edit incident | PUT | `/api/v1/incidents/{id}` |
| 5 | Delete incident | DELETE | `/api/v1/incidents/{id}` |
| 6 | Resolve incident | PUT | `/api/v1/incidents/{id}/resolve` |

---

## Complete Operation Summary (All 17)

| # | Operation | Category |
|---|-----------|----------|
| 1 | Login | Auth |
| 2 | Logout | Auth |
| 3 | List Application Groups | Groups |
| 4 | View Application Group | Groups |
| 5 | Create Application Group | Groups |
| 6 | Edit Application Group | Groups |
| 7 | Delete Application Group | Groups |
| 8 | List Applications | Applications |
| 9 | View Application | Applications |
| 10 | Create Application | Applications |
| 11 | Edit Application | Applications |
| 12 | Delete Application | Applications |
| 13 | List Incidents | Incidents |
| 14 | View Incident | Incidents |
| 15 | Create Incident | Incidents |
| 16 | Edit Incident | Incidents |
| 17 | Delete Incident | Incidents |
| +  | Resolve Incident (bonus) | Incidents |

---

## Example Usage

### Login

```
Choose an option: 1

=== Login ===

Email: admin@example.com
Password: ********
[SUCCESS] Logged in successfully!
```

### Create an Application Group

```
Choose: 3

=== Create Application Group ===

Name: Production Services
Description: All production-facing services
{
    "id": 1,
    "name": "Production Services",
    "description": "All production-facing services",
    "created_at": "2024-01-15T10:00:00Z"
}
```

### Create an Application

```
Choose: 3

=== Create Application ===

Name: Payment Gateway
URL: https://pay.example.com
Description: Stripe payment integration
{
    "id": 42,
    "name": "Payment Gateway",
    "url": "https://pay.example.com",
    ...
}
```

### Create an Incident

```
Choose: 3

=== Create Incident ===

Title: Payment Gateway Down
Description: Gateway returning 503 errors
Application ID: 42
Severity (low/medium/high/critical): critical
{
    "id": 7,
    "title": "Payment Gateway Down",
    "severity": "critical",
    "status": "open",
    ...
}
```

### Resolve an Incident

```
Choose: 6

=== Resolve Incident ===

Incident ID to resolve: 7
Resolve incident 7? (y/n): y
[SUCCESS] Resolve request sent.
```

---

## API Base URL

All requests are sent to:

```
https://monitoring-app.on-forge.com
```

This is configured in `config.sh` under the `BASE_URL` variable. To point the CLI at a different environment (e.g., staging), edit that variable:

```bash
BASE_URL="https://staging.monitoring-app.on-forge.com"
```

---

## File Structure

```
monitoringapp-cli/
├── monitoring-cli.sh   # Main executable — run this
├── config.sh           # Shared helpers, colors, API functions
├── .gitignore          # Excludes credentials and logs
└── README.md           # This file
```

---

## Troubleshooting

### `curl: command not found`

Install curl for your OS:

```bash
# Debian/Ubuntu
sudo apt install curl

# macOS (Homebrew)
brew install curl

# RHEL/CentOS
sudo yum install curl
```

### `python3: command not found`

JSON output will fall back to raw unformatted text — the CLI still works. To get pretty-printed JSON, install Python 3:

```bash
# Debian/Ubuntu
sudo apt install python3

# macOS (Homebrew)
brew install python3
```

### Authentication Errors

- Ensure you are using the correct email and password for `https://monitoring-app.on-forge.com`.
- The token is stored in memory only. If you open a new terminal session, you must log in again.
- If you see `Login failed` with a JSON error body, check the `message` or `error` field in the output for details.

### `bash: ./monitoring-cli.sh: Permission denied`

Run `chmod +x monitoring-cli.sh` to make it executable, or invoke it as `bash monitoring-cli.sh`.

### Script Works on macOS but Not Linux (or vice versa)

Make sure you are using Bash 4+. macOS ships with Bash 3.2 by default. Install a newer version via Homebrew:

```bash
brew install bash
/usr/local/bin/bash monitoring-cli.sh
```

---

## Group Members

- <!-- Member 1 Name -->
- <!-- Member 2 Name -->
- <!-- Member 3 Name -->
- <!-- Member 4 Name -->

---

## License

This project is submitted as part of a course assignment. All rights reserved by the team members listed above.
