# Diagnostic Erreur 400 - Guide de Résolution

## 🔍 DIAGNOSTIC ÉTAPE PAR ÉTAPE

### Étape 1: Uploader les fichiers mis à jour

Uploadez ces fichiers modifiés sur fidest.ci:

- `register.php` (avec debug ajouté)
- `login.php` (avec debug ajouté)
- `debug.php` (nouveau fichier de test)

### Étape 2: Tests API avec navigateur

#### Test 1 - Vérification générale

Visitez: `https://fidest.ci/rencontre/backend-api/api/debug.php`
✅ **Attendu**: JSON avec "success": true

#### Test 2 - Test d'inscription

Visitez: `https://fidest.ci/rencontre/backend-api/api/debug.php?action=register`
✅ **Attendu**: Création ou confirmation d'utilisateur test

#### Test 3 - Test endpoint réel

Utilisez un outil comme Postman ou le navigateur pour tester:

```
POST https://fidest.ci/rencontre/backend-api/api/register.php
Content-Type: application/json

{
  "email": "test@example.com",
  "password": "test123",
  "firstName": "Test",
  "lastName": "User",
  "phone": "0123456789"
}
```

### Étape 3: Vérifier les logs d'erreur

Dans cPanel de fidest.ci:

1. Aller dans "Error Logs"
2. Chercher les entrées récentes avec "REGISTER DEBUG" ou "LOGIN DEBUG"
3. Noter les erreurs exactes

### Étape 4: Solutions possibles selon les erreurs

#### Si "Données JSON invalides":

- Problème de Content-Type ou données mal formées
- Vérifier que Flutter envoie bien du JSON

#### Si "Erreur de base de données":

- Table users n'existe pas ou problème de connexion MySQL
- Vérifier les credentials de DB dans config.php

#### Si "Email déjà utilisé":

- Normal, changer d'email de test ou supprimer l'utilisateur existant

### Étape 5: Test depuis l'app mobile

Une fois l'API confirmée fonctionnelle:

1. Essayer l'inscription depuis l'app
2. Vérifier les logs PHP pour voir les données reçues
3. Comparer avec le test manuel

## 🚨 ACTIONS IMMÉDIATES

1. **UPLOADER** les 3 fichiers modifiés
2. **TESTER** debug.php dans le navigateur
3. **VÉRIFIER** les logs d'erreur cPanel
4. **REPORTER** les messages d'erreur exacts trouvés

---

**En attendant les résultats des tests, l'app continuera de fonctionner en mode hors ligne.**
