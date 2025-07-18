# Guide d'Installation Complet - Compagnie Sociale CI

## 🎯 Vue d'ensemble de l'architecture

```
Flutter App (Mobile) ↔ API REST (PHP) ↔ MySQL (tpecloud)
       ↓
   SQLite (Local/Offline)
```

## 📋 Étapes d'installation

### 1. Configuration de la base de données MySQL sur tpecloud

1. **Connexion à votre panneau tpecloud**

   - Connectez-vous à votre compte tpecloud
   - Accédez à la section "Bases de données"

2. **Créer la base de données**

   - Créez une nouvelle base de données MySQL
   - Nom suggéré: `compagnie_sociale_ci`
   - Notez les informations de connexion

3. **Exécuter le script SQL**
   - Ouvrez phpMyAdmin ou l'outil de gestion MySQL de tpecloud
   - Importez le fichier `database_schema.sql`
   - Vérifiez que toutes les tables sont créées

### 2. Déploiement de l'API sur tpecloud

1. **Upload des fichiers**

   - Compressez le dossier `backend-api` en ZIP
   - Uploadez via le gestionnaire de fichiers de tpecloud
   - Décompressez dans le dossier public de votre domaine

2. **Configuration de la base de données**

   - Modifiez `config/database.php` avec vos informations MySQL:

   ```php
   private $host = "votre-host-mysql.tpecloud.com";
   private $db_name = "compagnie_sociale_ci";
   private $username = "votre_username";
   private $password = "votre_password";
   ```

3. **Test de l'API**
   - Testez l'endpoint health: `https://votre-domaine.com/api/health.php`
   - Vous devriez voir un JSON de confirmation

### 3. Configuration de l'application Flutter

1. **Modifier l'URL de l'API**

   - Dans `lib/services/api_service.dart`, ligne 8:

   ```dart
   static const String baseUrl = 'https://votre-domaine.tpecloud.com/api';
   ```

2. **Installer les dépendances**

   ```bash
   flutter pub get
   ```

3. **Tester l'application**
   ```bash
   flutter run
   ```

## 🔧 Configuration avancée

### Fichier .htaccess (optionnel)

Créez un fichier `.htaccess` dans le dossier `api` pour gérer les CORS:

```apache
Header always set Access-Control-Allow-Origin "*"
Header always set Access-Control-Allow-Methods "GET,POST,PUT,DELETE,OPTIONS"
Header always set Access-Control-Allow-Headers "Content-Type,Authorization,X-Requested-With"

RewriteEngine On
RewriteCond %{REQUEST_METHOD} OPTIONS
RewriteRule ^(.*)$ $1 [R=200,L]
```

### SSL/HTTPS

- Assurez-vous que votre domaine tpecloud a un certificat SSL
- L'application Flutter nécessite HTTPS pour les connexions API

## 🧪 Tests de fonctionnement

### 1. Test de l'API

```bash
# Test health check
curl https://votre-domaine.com/api/health.php

# Test inscription
curl -X POST https://votre-domaine.com/api/auth/register.php \
  -H "Content-Type: application/json" \
  -d '{"email":"test@test.com","password":"123456","fullName":"Test User"}'
```

### 2. Test de l'application

1. Lancez l'app Flutter
2. Essayez de créer un compte
3. Essayez de vous connecter
4. Vérifiez que les données apparaissent dans votre base MySQL

## 🔒 Sécurité

### Recommandations de production:

1. **Changer les mots de passe par défaut**
2. **Implémenter JWT pour l'authentification**
3. **Ajouter la validation côté serveur**
4. **Configurer les logs d'erreur**
5. **Limiter les requêtes (rate limiting)**

## 📱 Fonctionnalités implémentées

✅ **Authentification**

- Inscription utilisateur
- Connexion/Déconnexion
- Gestion des sessions

✅ **Base de données**

- SQLite local (mode hors ligne)
- MySQL distant (mode en ligne)
- Synchronisation automatique

✅ **Interface utilisateur**

- Écrans d'authentification
- Navigation principale
- Profil utilisateur

## 🚀 Prochaines étapes

1. **Compléter l'API** (companions, bookings, messages)
2. **Implémenter la recherche**
3. **Ajouter les notifications push**
4. **Système de paiement**
5. **Chat en temps réel**

## 📞 Support

En cas de problème:

1. Vérifiez les logs d'erreur de tpecloud
2. Testez l'endpoint health de l'API
3. Vérifiez la connectivité réseau de l'app
4. Consultez les logs de debug Flutter

---

**Astuce**: Commencez par tester l'API avec des outils comme Postman avant de l'intégrer dans Flutter !
