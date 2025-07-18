# API Backend - Compagnie Sociale CI

## Installation sur tpecloud

### 1. Créer la base de données MySQL

1. Connectez-vous à votre panneau de contrôle tpecloud
2. Créez une nouvelle base de données MySQL
3. Exécutez le script `database_schema.sql` dans votre base de données
4. Notez les informations de connexion (host, username, password, database name)

### 2. Configurer l'API

1. Uploadez tous les fichiers du dossier `backend-api` sur votre serveur
2. Modifiez le fichier `config/database.php` avec vos informations de connexion MySQL
3. Assurez-vous que les dossiers ont les bonnes permissions (755 pour les dossiers, 644 pour les fichiers)

### 3. Structure des endpoints

```
Votre domaine/api/
├── auth/
│   ├── register.php    (POST) - Inscription
│   └── login.php       (POST) - Connexion
├── users/
│   ├── profile.php     (GET/PUT) - Profil utilisateur
│   └── update.php      (PUT) - Mise à jour utilisateur
├── companions/
│   ├── list.php        (GET) - Liste des compagnons
│   └── create.php      (POST) - Créer un profil compagnon
├── bookings/
│   ├── create.php      (POST) - Créer une réservation
│   └── list.php        (GET) - Liste des réservations
└── health.php          (GET) - Vérification API
```

### 4. Modifier l'URL dans Flutter

Dans votre app Flutter, modifiez le fichier `lib/services/api_service.dart` :

```dart
static const String baseUrl = 'https://votre-domaine.tpecloud.com/api';
```

### 5. Test de l'API

Testez d'abord l'endpoint health :

```
GET https://votre-domaine.tpecloud.com/api/health.php
```

Vous devriez recevoir :

```json
{
  "status": "OK",
  "message": "API is online and database connection is working",
  "timestamp": "2025-01-18 15:30:00",
  "version": "1.0.0"
}
```

### 6. Configuration CORS

Si vous avez des problèmes CORS, ajoutez un fichier `.htaccess` :

```apache
Header always set Access-Control-Allow-Origin "*"
Header always set Access-Control-Allow-Methods "GET,POST,PUT,DELETE,OPTIONS"
Header always set Access-Control-Allow-Headers "Content-Type,Authorization,X-Requested-With"
Header always set Access-Control-Max-Age "3600"

RewriteEngine On
RewriteCond %{REQUEST_METHOD} OPTIONS
RewriteRule ^(.*)$ $1 [R=200,L]
```

## Sécurité

- Les mots de passe sont hashés avec `password_hash()` de PHP
- Validation et nettoyage des entrées
- Tokens de base pour l'authentification (à améliorer avec JWT en production)

## Prochaines étapes

1. Implémenter tous les endpoints manquants
2. Ajouter une vraie gestion JWT
3. Ajouter la validation côté serveur
4. Implémenter les uploads d'images
5. Ajouter les logs d'erreur
