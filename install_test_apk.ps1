# Script d'installation et test de l'APK
Write-Host "=== INSTALLATION ET TEST APK ===" -ForegroundColor Green

$apkPath = "build\app\outputs\flutter-apk\app-debug.apk"

if (Test-Path $apkPath) {
    Write-Host "APK trouvé: $apkPath" -ForegroundColor Green
    Write-Host "Taille: $((Get-Item $apkPath).Length / 1MB) MB" -ForegroundColor Yellow
    
    Write-Host "`nVérification des appareils connectés..." -ForegroundColor Cyan
    adb devices
    
    Write-Host "`nInstallation de l'APK..." -ForegroundColor Cyan
    adb install -r $apkPath
    
    Write-Host "`nDémarrage des logs..." -ForegroundColor Cyan
    Write-Host "Utilisez Ctrl+C pour arrêter les logs" -ForegroundColor Yellow
    Write-Host "Recherchez les messages avec 'DEBUG' ou 'ERROR'" -ForegroundColor Yellow
    Write-Host "`n--- LOGS ---" -ForegroundColor Green
    
    # Filtrer les logs pour notre application
    adb logcat -c # Nettoyer les logs
    adb logcat | Select-String -Pattern "(flutter|DEBUG|ERROR|Exception|HTTP)"
    
} else {
    Write-Host "ERREUR: APK non trouvé à $apkPath" -ForegroundColor Red
    Write-Host "Veuillez d'abord exécuter: flutter build apk --debug" -ForegroundColor Yellow
}
