# Script de test pour l'API
Write-Host "=== TEST API LOGIN ===" -ForegroundColor Green

# Données de test (identiques à celles dans l'app Flutter)
$email = "amani@hotmail.com"
$password = "admin123"
$url = "https://fidest.ci/rencontre/backend-api/api/login.php"

# Corps de la requête JSON
$body = @{
    email = $email
    password = $password
} | ConvertTo-Json

Write-Host "URL: $url" -ForegroundColor Yellow
Write-Host "Email: $email" -ForegroundColor Yellow
Write-Host "Password length: $($password.Length)" -ForegroundColor Yellow
Write-Host "Body: $body" -ForegroundColor Yellow

try {
    # Headers identiques à Flutter
    $headers = @{
        "Content-Type" = "application/json"
        "User-Agent" = "CompagnieSociale/1.0"
        "Accept" = "application/json"
    }
    
    Write-Host "`n--- Requête avec headers Flutter ---" -ForegroundColor Cyan
    $response = Invoke-RestMethod -Uri $url -Method POST -Body $body -Headers $headers -ErrorAction Stop
    
    Write-Host "Status: SUCCESS" -ForegroundColor Green
    Write-Host "Response:" -ForegroundColor Green
    $response | ConvertTo-Json -Depth 10
    
} catch {
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    if ($_.Exception.Response) {
        Write-Host "Status Code: $($_.Exception.Response.StatusCode)" -ForegroundColor Red
        Write-Host "Status Description: $($_.Exception.Response.StatusDescription)" -ForegroundColor Red
    }
}

Write-Host "`n=== Test terminé ===" -ForegroundColor Green
