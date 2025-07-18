# API Backend pour Compagnie Sociale CI

## Structure des fichiers API

```
backend-api/
├── api/
│   ├── config.php          # Configuration base de données et utilitaires
│   ├── register.php        # Endpoint d'inscription
│   ├── login.php          # Endpoint de connexion
│   ├── sync_user.php      # Endpoint de synchronisation automatique
│   └── test.php           # Test de l'API et création de table
```

## Instructions de déploiement sur fidest.ci

### 1. Préparation des fichiers

Tous les fichiers PHP sont prêts dans le dossier `backend-api/api/`

### 2. Configuration de la base de données

Modifier le fichier `config.php` avec vos informations de base de données :

```php
// Remplacer ces valeurs par vos informations réelles
define('DB_HOST', 'localhost');
define('DB_NAME', 'votre_base_de_donnees');
define('DB_USER', 'votre_utilisateur');
define('DB_PASS', 'votre_mot_de_passe');
```

### 3. Upload des fichiers

1. Connectez-vous à votre hébergement fidest.ci via FTP/cPanel
2. Naviguez vers le dossier `public_html` ou équivalent
3. Créez la structure : `public_html/rencontre/backend-api/api/`
4. Uploadez tous les fichiers PHP dans ce dossier

### 4. Test de l'API

Après upload, testez l'API :

- URL de test : `https://fidest.ci/rencontre/backend-api/api/test.php`
- Cette URL doit retourner un JSON confirmant que l'API fonctionne

### 5. Endpoints disponibles

#### POST /register.php

Inscription d'un nouvel utilisateur

```json
{
  "email": "user@example.com",
  "password": "motdepasse",
  "firstName": "Prénom",
  "lastName": "Nom",
  "phone": "0123456789"
}
```

#### POST /login.php

Connexion d'un utilisateur

```json
{
  "email": "user@example.com",
  "password": "motdepasse"
}
```

#### POST /sync_user.php

Synchronisation automatique (utilisé par l'app)

```json
{
  "user": {
    "id": "uuid",
    "email": "user@example.com",
    "firstName": "Prénom",
    "lastName": "Nom",
    "phone": "0123456789",
    "isPremium": false,
    "preferences": []
  }
}
```

## Sécurité

- CORS configuré pour accepter toutes les origines
- Mots de passe hashés avec bcrypt
- Validation des données d'entrée
- Protection contre l'injection SQL avec PDO

## Base de données

La table `users` sera créée automatiquement lors du premier test de l'API.

## Résolution du problème 302

Une fois ces fichiers uploadés sur fidest.ci, l'erreur 302 devrait être résolue car les endpoints existeront.
