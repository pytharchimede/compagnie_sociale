# Script de diagnostic simple
Write-Host "=== DIAGNOSTIC DE L'APPLICATION ===" -ForegroundColor Green

$debugApk = "build\app\outputs\flutter-apk\app-debug.apk"
$releaseApk = "build\app\outputs\flutter-apk\app-release.apk"

Write-Host "--- Etat des APK ---" -ForegroundColor Cyan
if (Test-Path $debugApk) {
    $debugSize = [math]::Round((Get-Item $debugApk).Length / 1MB, 1)
    Write-Host "Debug APK: $debugApk ($debugSize MB)" -ForegroundColor Green
} else {
    Write-Host "Debug APK: Non trouve" -ForegroundColor Red
}

if (Test-Path $releaseApk) {
    $releaseSize = [math]::Round((Get-Item $releaseApk).Length / 1MB, 1)
    Write-Host "Release APK: $releaseApk ($releaseSize MB)" -ForegroundColor Green
} else {
    Write-Host "Release APK: Non trouve" -ForegroundColor Red
}

Write-Host "--- Test API ---" -ForegroundColor Cyan
try {
    $body = '{"email":"amani@hotmail.com","password":"admin123"}'
    $result = Invoke-RestMethod -Uri "https://fidest.ci/rencontre/backend-api/api/login.php" -Method POST -Body $body -ContentType "application/json"
    if ($result.success) {
        Write-Host "API fonctionne correctement" -ForegroundColor Green
        Write-Host "User: $($result.user.firstName) $($result.user.lastName)" -ForegroundColor Yellow
    } else {
        Write-Host "API retourne une erreur: $($result.message)" -ForegroundColor Red
    }
} catch {
    Write-Host "Erreur API: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "--- Recommandations ---" -ForegroundColor Cyan
Write-Host "1. Installer l'APK Debug sur votre telephone"
Write-Host "2. Ouvrir l'application"  
Write-Host "3. Cliquer sur 'Test Connexion API' d'abord"
Write-Host "4. Si le test fonctionne, utiliser 'Se connecter'"
Write-Host "5. Verifier les logs Android avec: adb logcat | findstr flutter"

Write-Host "=== Pret pour les tests ===" -ForegroundColor Green
