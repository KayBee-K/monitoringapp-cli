# CLI MonitoringApp

Un CLI entièrement interactif et piloté par menu pour l'**API REST MonitoringApp**. Gérez les groupes d'applications, les applications et les incidents directement depuis votre terminal.

**Disponible en deux versions:**
- **Bash** (`monitoring-cli.sh`) — pour Linux, macOS et WSL
- **PowerShell** (`monitoring-cli.ps1`) — pour Windows PowerShell 5.1+

---

## Description du projet

CLI MonitoringApp fournit une interface de terminal conviviale pour interagir avec la plateforme MonitoringApp hébergée à `https://monitoring-app.on-forge.com`. Au lieu de créer des commandes `curl` brutes, cet outil présente des menus hiérarchiques qui vous guident à travers l'authentification et toutes les opérations CRUD sur trois types de ressources:

- **Groupes d'applications** — regroupements logiques d'applications
- **Applications** — services ou points de terminaison individuels surveillés
- **Incidents** — événements ou pannes associés aux applications

Le CLI maintient votre jeton de session en mémoire pendant la durée de la session. Les identifiants ne sont jamais écrits sur le disque.

---

## Prérequis

### Version Bash

| Exigence | Version               | Remarques                                                 |
| -------- | --------------------- | --------------------------------------------------------- |
| Bash     | 4.0+                  | Requis pour `read -r`, les tableaux et `[[ ]]`            |
| curl     | Toute version récente | Utilisé pour toutes les requêtes HTTP                     |
| python3  | 3.x (optionnel)       | Utilisé pour le formatage JSON; revient à la sortie brute |

### Version PowerShell

| Exigence  | Version | Remarques                                                                      |
| --------- | ------- | ------------------------------------------------------------------------------ |
| PowerShell | 5.1+   | Inclus nativement dans Windows 10+ et Windows Server 2016+                    |
| (aucun)   | —       | `Invoke-WebRequest` et `ConvertFrom-Json` sont des cmdlets PowerShell natifs |

### Vérifier les prérequis

```bash
bash --version
curl --version
python3 --version
```

---

## Instructions d'installation

### 1. Cloner ou télécharger

```bash
git clone <repo-url> monitoringapp-cli
cd monitoringapp-cli
```

### 2. Rendre le script principal exécutable

```bash
chmod +x monitoring-cli.sh
```

> `config.sh` n'a pas besoin d'être exécutable — il est fourni par `monitoring-cli.sh`.

### 3. Exécuter le CLI

**Bash (Linux/macOS/WSL):**

```bash
./monitoring-cli.sh
```

Ou via bash explicitement:

```bash
bash monitoring-cli.sh
```

**PowerShell (Windows):**

Ouvrez PowerShell et naviguez vers le répertoire du projet:

```powershell
cd D:\Workspace\monitoringapp-cli
powershell -ExecutionPolicy Bypass -File .\monitoring-cli.ps1
```

Ou si PowerShell est déjà ouvert:

```powershell
& .\monitoring-cli.ps1
```

> **Remarque:** La première commande contourne temporairement la politique d'exécution pour ce script uniquement. Elle ne change pas les paramètres système.

---

## Visite guidée du menu

Lorsque vous lancez le CLI, vous verrez le **Tableau de bord principal**:

```
╔══════════════════════════════════════╗
║   Tableau de bord CLI MonitoringApp   ║
╚══════════════════════════════════════╝

  Statut: ● Non connecté

  1) Connexion
  2) Gérer les groupes
  3) Gérer les applications
  4) Gérer les incidents
  5) Déconnexion
  6) Quitter
```

### Options du menu principal

| Option | Description                                                            |
| ------ | ---------------------------------------------------------------------- |
| 1      | S'authentifier auprès de l'API à l'aide de l'e-mail et du mot de passe |
| 2      | Accédez au sous-menu Groupes d'applications                            |
| 3      | Accédez au sous-menu Applications                                      |
| 4      | Accédez au sous-menu Incidents                                         |
| 5      | Effacer le jeton de session (déconnexion)                              |
| 6      | Quitter le programme                                                   |

---

### Sous-menu: Gérer les groupes d'applications (17 opérations au total — 5 ici)

```
  1) Lister tous les groupes
  2) Afficher le groupe par ID
  3) Créer un nouveau groupe
  4) Modifier le groupe
  5) Supprimer le groupe
  0) Retour au menu principal
```

| #   | Opération                 | Méthode HTTP | Point de terminaison              |
| --- | ------------------------- | ------------ | --------------------------------- |
| 1   | Lister tous les groupes   | GET          | `/api/v1/application-groups`      |
| 2   | Afficher le groupe par ID | GET          | `/api/v1/application-groups/{id}` |
| 3   | Créer un nouveau groupe   | POST         | `/api/v1/application-groups`      |
| 4   | Modifier le groupe        | PUT          | `/api/v1/application-groups/{id}` |
| 5   | Supprimer le groupe       | DELETE       | `/api/v1/application-groups/{id}` |

---

### Sous-menu: Gérer les applications (5 opérations)

```
  1) Lister toutes les applications
  2) Afficher l'application par ID
  3) Créer une nouvelle application
  4) Modifier l'application
  5) Supprimer l'application
  0) Retour au menu principal
```

| #   | Opération                      | Méthode HTTP | Point de terminaison        |
| --- | ------------------------------ | ------------ | --------------------------- |
| 1   | Lister toutes les applications | GET          | `/api/v1/applications`      |
| 2   | Afficher l'application par ID  | GET          | `/api/v1/applications/{id}` |
| 3   | Créer une nouvelle application | POST         | `/api/v1/applications`      |
| 4   | Modifier l'application         | PUT          | `/api/v1/applications/{id}` |
| 5   | Supprimer l'application        | DELETE       | `/api/v1/applications/{id}` |

---

### Sous-menu: Gérer les incidents (6 opérations + connexion/déconnexion = 17 au total)

```
  1) Lister tous les incidents
  2) Afficher l'incident par ID
  3) Créer un nouvel incident
  4) Modifier l'incident
  5) Supprimer l'incident
  6) Résoudre l'incident
  0) Retour au menu principal
```

| #   | Opération                  | Méthode HTTP | Point de terminaison             |
| --- | -------------------------- | ------------ | -------------------------------- |
| 1   | Lister tous les incidents  | GET          | `/api/v1/incidents`              |
| 2   | Afficher l'incident par ID | GET          | `/api/v1/incidents/{id}`         |
| 3   | Créer un nouvel incident   | POST         | `/api/v1/incidents`              |
| 4   | Modifier l'incident        | PUT          | `/api/v1/incidents/{id}`         |
| 5   | Supprimer l'incident       | DELETE       | `/api/v1/incidents/{id}`         |
| 6   | Résoudre l'incident        | PUT          | `/api/v1/incidents/{id}/resolve` |

---

## Résumé complet des opérations (Les 17)

| #   | Opération                          | Catégorie    |
| --- | ---------------------------------- | ------------ |
| 1   | Connexion                          | Auth         |
| 2   | Déconnexion                        | Auth         |
| 3   | Lister les groupes d'applications  | Groupes      |
| 4   | Afficher le groupe d'applications  | Groupes      |
| 5   | Créer un groupe d'applications     | Groupes      |
| 6   | Modifier le groupe d'applications  | Groupes      |
| 7   | Supprimer le groupe d'applications | Groupes      |
| 8   | Lister les applications            | Applications |
| 9   | Afficher l'application             | Applications |
| 10  | Créer une application              | Applications |
| 11  | Modifier l'application             | Applications |
| 12  | Supprimer l'application            | Applications |
| 13  | Lister les incidents               | Incidents    |
| 14  | Afficher l'incident                | Incidents    |
| 15  | Créer un incident                  | Incidents    |
| 16  | Modifier l'incident                | Incidents    |
| 17  | Supprimer l'incident               | Incidents    |
| +   | Résoudre l'incident (bonus)        | Incidents    |

---

## Exemple d'utilisation

### Connexion

```
Choisissez une option: 1

=== Connexion ===

E-mail: admin@example.com
Mot de passe: ********
[SUCCÈS] Connecté avec succès!
```

### Créer un groupe d'applications

```
Choisir: 3

=== Créer un groupe d'applications ===

Nom: Services de production
Description: Tous les services externes
{
    "id": 1,
    "name": "Services de production",
    "description": "Tous les services externes",
    "created_at": "2024-01-15T10:00:00Z"
}
```

### Créer une application

```
Choisir: 3

=== Créer une application ===

Nom: Passerelle de paiement
URL: https://pay.example.com
Description: Intégration de paiement Stripe
{
    "id": 42,
    "name": "Passerelle de paiement",
    "url": "https://pay.example.com",
    ...
}
```

### Créer un incident

```
Choisir: 3

=== Créer un incident ===

Titre: Passerelle de paiement hors ligne
Description: La passerelle renvoie des erreurs 503
ID de l'application: 42
Sévérité (faible/moyen/élevé/critique): critique
{
    "id": 7,
    "title": "Passerelle de paiement hors ligne",
    "severity": "critique",
    "status": "ouvert",
    ...
}
```

### Résoudre un incident

```
Choisir: 6

=== Résoudre l'incident ===

ID de l'incident à résoudre: 7
Résoudre l'incident 7? (o/n): o
[SUCCÈS] Demande de résolution envoyée.
```

---

## URL de base de l'API

Toutes les demandes sont envoyées à:

```
https://monitoring-app.on-forge.com
```

**Pour Bash:** Ceci est configuré dans `config.sh` sous la variable `BASE_URL`:

```bash
BASE_URL="https://staging.monitoring-app.on-forge.com"
```

**Pour PowerShell:** Ceci est configuré dans `config.ps1` sous la variable `$script:BASE_URL`:

```powershell
$script:BASE_URL = "https://staging.monitoring-app.on-forge.com"
```

Pour pointer le CLI vers un environnement différent (p. ex. staging), modifiez ces variables.

---

## Structure des fichiers

```
monitoringapp-cli/
├── monitoring-cli.sh   # Version Bash — exécutez ceci sur Linux/macOS
├── config.sh           # Aides Bash partagées, couleurs, fonctions API
├── monitoring-cli.ps1  # Version PowerShell — exécutez ceci sur Windows
├── config.ps1          # Aides PowerShell partagées, couleurs, fonctions API
├── .gitignore          # Exclut les identifiants et les journaux
└── README.md           # Ce fichier
```

---

## Dépannage

### `curl: command not found`

Installez curl pour votre système d'exploitation:

```bash
# Debian/Ubuntu
sudo apt install curl

# macOS (Homebrew)
brew install curl

# RHEL/CentOS
sudo yum install curl
```

### `python3: command not found`

La sortie JSON revient au texte brut non formaté — le CLI fonctionne toujours. Pour obtenir du JSON joliment imprimé, installez Python 3:

```bash
# Debian/Ubuntu
sudo apt install python3

# macOS (Homebrew)
brew install python3
```

### Erreurs d'authentification

- Assurez-vous que vous utilisez l'e-mail et le mot de passe corrects pour `https://monitoring-app.on-forge.com`.
- Le jeton est stocké en mémoire uniquement. Si vous ouvrez une nouvelle session de terminal, vous devez vous reconnecter.
- Si vous voyez `Connexion échouée` avec un corps d'erreur JSON, vérifiez le champ `message` ou `error` dans la sortie pour plus de détails.

### `bash: ./monitoring-cli.sh: Permission denied`

Exécutez `chmod +x monitoring-cli.sh` pour le rendre exécutable, ou invoquez-le en tant que `bash monitoring-cli.sh`.

### Le script fonctionne sur macOS mais pas sur Linux (ou vice-versa)

Assurez-vous que vous utilisez Bash 4+. macOS est fourni avec Bash 3.2 par défaut. Installez une version plus récente via Homebrew:

```bash
brew install bash
/usr/local/bin/bash monitoring-cli.sh
```

---

## Dépannage PowerShell

### `"PowerShell" is not recognized as an internal or external command`

PowerShell n'est pas dans votre PATH. Sur Windows 10+, ouvrez simplement le menu Démarrer et tapez `PowerShell`. Ou utilisez **Windows Terminal** (recommandé):

```powershell
# Windows Terminal (l'onglet PowerShell par défaut)
cd D:\Workspace\monitoringapp-cli
powershell -ExecutionPolicy Bypass -File .\monitoring-cli.ps1
```

### `File cannot be loaded because running scripts is disabled on this system`

Votre politique d'exécution PowerShell est stricte. Utilisez la commande avec `-ExecutionPolicy Bypass`:

```powershell
powershell -ExecutionPolicy Bypass -File "D:\Workspace\monitoringapp-cli\monitoring-cli.ps1"
```

Ceci n'affecte que ce script, pas vos paramètres système.

### Caractères corrompus (texte français mal affiché)

Le script PowerShell utilise des caractères ASCII simples pour éviter les problèmes d'encodage. Si vous voyez toujours des caractères brisés, mettez à jour PowerShell:

```powershell
# Windows 10+, ouvrir le Microsoft Store et rechercher "Windows Terminal"
# Ou installer via winget:
winget install Microsoft.PowerShell
```

### La couleur des messages n'apparaît pas

Assurez-vous que vous utilisez **Windows Terminal** ou une version récente de PowerShell ISE. Les anciennes invites PowerShell legacy supportent mal les couleurs. Windows Terminal est recommandé.

---

## Membres du groupe

- <!-- Nom du membre 1 -->
- <!-- Nom du membre 2 -->
- <!-- Nom du membre 3 -->
- <!-- Nom du membre 4 -->

---

## Licence

Ce projet est soumis dans le cadre d'une affectation de cours. Tous les droits sont réservés par les membres de l'équipe listés ci-dessus.
