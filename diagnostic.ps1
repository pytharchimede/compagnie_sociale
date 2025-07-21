# Script de test et diagnostic
Write-Host "=== DIAGNOSTIC DE L'APPLICATION ===" -ForegroundColor Green

$debugApk = "build\app\outputs\flutter-apk\app-debug.apk"
$releaseApk = "build\app\outputs\flutter-apk\app-release.apk"

Write-Host "`n--- État des APK ---" -ForegroundColor Cyan
if (Test-Path $debugApk) {
    $debugSize = (Get-Item $debugApk).Length / 1MB
    Write-Host "✓ APK Debug: $debugApk ($([math]::Round($debugSize, 1)) MB)" -ForegroundColor Green
} else {
    Write-Host "✗ APK Debug: Non trouvé" -ForegroundColor Red
}

if (Test-Path $releaseApk) {
    $releaseSize = (Get-Item $releaseApk).Length / 1MB
    Write-Host "✓ APK Release: $releaseApk ($([math]::Round($releaseSize, 1)) MB)" -ForegroundColor Green
} else {
    Write-Host "✗ APK Release: Non trouvé" -ForegroundColor Red
}

Write-Host "`n--- Test API ---" -ForegroundColor Cyan
try {
    $testResult = Invoke-RestMethod -Uri "https://fidest.ci/rencontre/backend-api/api/login.php" -Method POST -Body '{"email":"amani@hotmail.com","password":"admin123"}' -ContentType "application/json" -ErrorAction Stop
    if ($testResult.success) {
        Write-Host "✓ API fonctionne correctement" -ForegroundColor Green
        Write-Host "  User: $($testResult.user.firstName) $($testResult.user.lastName)" -ForegroundColor Yellow
    } else {
        Write-Host "✗ API retourne une erreur: $($testResult.message)" -ForegroundColor Red
    }
} catch {
    Write-Host "✗ Erreur API: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n--- Recommandations ---" -ForegroundColor Cyan
Write-Host "1. Installer l'APK Debug sur votre téléphone" -ForegroundColor Yellow
Write-Host "2. Ouvrir l'application" -ForegroundColor Yellow
Write-Host "3. Cliquer sur 'Test Connexion API' d'abord" -ForegroundColor Yellow
Write-Host "4. Si le test fonctionne, utiliser 'Se connecter'" -ForegroundColor Yellow
Write-Host "5. Vérifier les logs Android avec: adb logcat | findstr flutter" -ForegroundColor Yellow

Write-Host "`n--- Prêt pour les tests ---" -ForegroundColor Green
