# Script de test de l'emulateur
Write-Host "=== ETAT DE L'EMULATEUR ===" -ForegroundColor Green

Write-Host "Appareils connectes:" -ForegroundColor Cyan
adb devices

Write-Host "`nApplications installees (compagnie_sociale):" -ForegroundColor Cyan
adb shell pm list packages | findstr compagnie

Write-Host "`nInformations de l'application:" -ForegroundColor Cyan
adb shell dumpsys package com.example.compagnie_sociale_ci | Select-String -Pattern "(versionName|versionCode|firstInstallTime)"

Write-Host "`nPour lancer l'app manuellement:" -ForegroundColor Yellow
Write-Host "adb shell am start -n com.example.compagnie_sociale_ci/com.example.compagnie_sociale_ci.MainActivity"

Write-Host "`nPour voir les logs:" -ForegroundColor Yellow
Write-Host "powershell -File watch_logs.ps1"

Write-Host "`n=== Instructions ===" -ForegroundColor Green
Write-Host "1. Ouvrez l'application sur l'emulateur"
Write-Host "2. Utilisez les identifiants: amani@hotmail.com / admin123"
Write-Host "3. Essayez d'abord 'TEST DIRECT' puis 'Se connecter'"
Write-Host "4. Surveillez les logs avec watch_logs.ps1"
