# Script de surveillance des logs Flutter
Write-Host "=== SURVEILLANCE DES LOGS FLUTTER ===" -ForegroundColor Green
Write-Host "Application installee sur emulator-5554" -ForegroundColor Yellow
Write-Host "Ouvrez l'application sur l'emulateur et essayez de vous connecter" -ForegroundColor Yellow
Write-Host "Les logs apparaitront ci-dessous..." -ForegroundColor Cyan
Write-Host "Appuyez sur Ctrl+C pour arreter" -ForegroundColor Red
Write-Host ""

# Surveiller les logs et filtrer pour Flutter et nos messages debug
adb logcat | Select-String -Pattern "(flutter|DEBUG|ERROR|Exception|LOGIN|API)"
