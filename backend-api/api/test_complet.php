<?php
// Script de test complet pour l'API
header('Content-Type: text/html; charset=UTF-8');

echo "<h1>Test Complet API Compagnie Sociale</h1>";

// Configuration
$baseUrl = 'https://fidest.ci/rencontre/backend-api/api';
$testEmail = 'test_api_' . time() . '@example.com';
$testPassword = 'test123456';

function makeApiCall($url, $data = null, $method = 'GET')
{
    $ch = curl_init();
    curl_setopt($ch, CURLOPT_URL, $url);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch, CURLOPT_TIMEOUT, 30);
    curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);

    if ($method === 'POST' && $data) {
        curl_setopt($ch, CURLOPT_POST, true);
        curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($data));
        curl_setopt($ch, CURLOPT_HTTPHEADER, [
            'Content-Type: application/json',
            'Accept: application/json'
        ]);
    }

    $response = curl_exec($ch);
    $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
    $error = curl_error($ch);
    curl_close($ch);

    return [
        'http_code' => $httpCode,
        'response' => $response,
        'error' => $error
    ];
}

echo "<h2>Étape 1: Test de connectivité API</h2>";
$result = makeApiCall($baseUrl . '/debug.php');
echo "<strong>URL:</strong> {$baseUrl}/debug.php<br>";
echo "<strong>Code HTTP:</strong> {$result['http_code']}<br>";
echo "<strong>Erreur cURL:</strong> " . ($result['error'] ?: 'Aucune') . "<br>";
echo "<strong>Réponse:</strong><br><pre>" . htmlspecialchars($result['response']) . "</pre>";

if ($result['http_code'] !== 200) {
    echo "<div style='color: red; font-weight: bold;'>❌ API non accessible!</div>";
    exit;
}

echo "<div style='color: green; font-weight: bold;'>✅ API accessible</div>";

echo "<h2>Étape 2: Création d'un utilisateur de test</h2>";
$registerData = [
    'email' => $testEmail,
    'password' => $testPassword,
    'firstName' => 'TestAPI',
    'lastName' => 'User',
    'phone' => '0123456789'
];

$result = makeApiCall($baseUrl . '/register.php', $registerData, 'POST');
echo "<strong>URL:</strong> {$baseUrl}/register.php<br>";
echo "<strong>Données envoyées:</strong><br><pre>" . json_encode($registerData, JSON_PRETTY_PRINT) . "</pre>";
echo "<strong>Code HTTP:</strong> {$result['http_code']}<br>";
echo "<strong>Réponse:</strong><br><pre>" . htmlspecialchars($result['response']) . "</pre>";

$registerResponse = json_decode($result['response'], true);

if ($result['http_code'] === 200 && isset($registerResponse['success']) && $registerResponse['success']) {
    echo "<div style='color: green; font-weight: bold;'>✅ Inscription réussie</div>";

    echo "<h2>Étape 3: Test de connexion</h2>";
    $loginData = [
        'email' => $testEmail,
        'password' => $testPassword
    ];

    $result = makeApiCall($baseUrl . '/login.php', $loginData, 'POST');
    echo "<strong>URL:</strong> {$baseUrl}/login.php<br>";
    echo "<strong>Données envoyées:</strong><br><pre>" . json_encode($loginData, JSON_PRETTY_PRINT) . "</pre>";
    echo "<strong>Code HTTP:</strong> {$result['http_code']}<br>";
    echo "<strong>Réponse:</strong><br><pre>" . htmlspecialchars($result['response']) . "</pre>";

    $loginResponse = json_decode($result['response'], true);

    if ($result['http_code'] === 200 && isset($loginResponse['success']) && $loginResponse['success']) {
        echo "<div style='color: green; font-weight: bold;'>✅ Connexion réussie</div>";

        echo "<h2>Étape 4: Test de synchronisation</h2>";
        $syncData = [
            'user' => [
                'id' => $loginResponse['user']['id'],
                'email' => $testEmail,
                'firstName' => 'TestAPISync',
                'lastName' => 'UserSync',
                'phone' => '0987654321',
                'isPremium' => true,
                'preferences' => ['theme' => 'dark']
            ]
        ];

        $result = makeApiCall($baseUrl . '/sync_user.php', $syncData, 'POST');
        echo "<strong>URL:</strong> {$baseUrl}/sync_user.php<br>";
        echo "<strong>Données envoyées:</strong><br><pre>" . json_encode($syncData, JSON_PRETTY_PRINT) . "</pre>";
        echo "<strong>Code HTTP:</strong> {$result['http_code']}<br>";
        echo "<strong>Réponse:</strong><br><pre>" . htmlspecialchars($result['response']) . "</pre>";

        $syncResponse = json_decode($result['response'], true);

        if ($result['http_code'] === 200 && isset($syncResponse['success']) && $syncResponse['success']) {
            echo "<div style='color: green; font-weight: bold;'>✅ Synchronisation réussie</div>";
            echo "<h1 style='color: green;'>🎉 TOUS LES TESTS SONT PASSÉS!</h1>";
        } else {
            echo "<div style='color: red; font-weight: bold;'>❌ Échec de la synchronisation</div>";
        }
    } else {
        echo "<div style='color: red; font-weight: bold;'>❌ Échec de la connexion</div>";
        echo "<div style='background: #ffebee; padding: 10px; margin: 10px 0;'>";
        echo "<strong>Diagnostic:</strong> Le problème est dans la vérification du mot de passe.<br>";
        echo "Vérifiez les logs d'erreur de votre hébergeur pour voir les détails du debug.";
        echo "</div>";
    }
} else {
    echo "<div style='color: red; font-weight: bold;'>❌ Échec de l'inscription</div>";
    if (isset($registerResponse['message'])) {
        echo "<div style='background: #ffebee; padding: 10px; margin: 10px 0;'>";
        echo "<strong>Message d'erreur:</strong> " . $registerResponse['message'];
        echo "</div>";
    }
}

echo "<h2>Informations utilisées</h2>";
echo "<strong>Email de test:</strong> {$testEmail}<br>";
echo "<strong>Mot de passe de test:</strong> {$testPassword}<br>";
echo "<strong>Base URL:</strong> {$baseUrl}<br>";

echo "<h2>Actions à faire</h2>";
echo "<ol>";
echo "<li>Si tous les tests passent: L'API fonctionne, le problème vient de l'app Flutter</li>";
echo "<li>Si l'inscription passe mais pas la connexion: Problème de hash de mot de passe</li>";
echo "<li>Si rien ne passe: Problème de configuration de base de données</li>";
echo "</ol>";

echo "<div style='background: #e3f2fd; padding: 15px; margin: 20px 0; border-left: 4px solid #2196f3;'>";
echo "<strong>🔍 Pour diagnostiquer plus en détail:</strong><br>";
echo "1. Consultez les logs d'erreur de votre hébergeur (cPanel → Error Logs)<br>";
echo "2. Cherchez les messages commençant par '=== LOGIN DEBUG ===' ou '=== REGISTER DEBUG ==='<br>";
echo "3. Notez les détails du hash et de la vérification de mot de passe";
echo "</div>";
