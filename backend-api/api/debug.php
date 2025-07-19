<?php
// Test simple de l'API
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

try {
    require_once 'config.php';

    // Test de connexion à la base
    $pdo = getDatabaseConnection();

    // Test POST pour register
    if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_GET['action']) && $_GET['action'] === 'register') {
        $testData = [
            'email' => 'test_debug@example.com',
            'password' => 'test123',
            'firstName' => 'TestDebug',
            'lastName' => 'User',
            'phone' => '0123456789'
        ];

        // Simuler l'inscription
        $email = $testData['email'];
        $password = $testData['password'];
        $firstName = $testData['firstName'];
        $lastName = $testData['lastName'];
        $phone = $testData['phone'];

        // Supprimer l'utilisateur existant d'abord
        $stmt = $pdo->prepare("DELETE FROM users WHERE email = ?");
        $stmt->execute([$email]);

        // Créer l'utilisateur test avec debug complet
        $userId = generateUUID();
        $hashedPassword = hashPassword($password);
        $fullName = $firstName . ' ' . $lastName;

        error_log("=== TEST USER CREATION ===");
        error_log("Plain password: " . $password);
        error_log("Hashed password: " . $hashedPassword);
        error_log("Verify test: " . (password_verify($password, $hashedPassword) ? 'SUCCESS' : 'FAILED'));

        $stmt = $pdo->prepare("
            INSERT INTO users (
                id, email, password, full_name, phone, 
                is_verified, is_premium, preferences, 
                created_at, updated_at
            ) VALUES (?, ?, ?, ?, ?, 0, 0, '[]', NOW(), NOW())
        ");

        $stmt->execute([
            $userId,
            $email,
            $hashedPassword,
            $fullName,
            $phone
        ]);

        echo json_encode([
            'success' => true,
            'message' => 'Utilisateur test créé avec succès',
            'user_id' => $userId,
            'test_credentials' => [
                'email' => $email,
                'password' => $password
            ],
            'hash_info' => [
                'plain' => $password,
                'hashed' => $hashedPassword,
                'verify_works' => password_verify($password, $hashedPassword)
            ],
            'test' => 'register'
        ]);
    } else {
        // Test général
        echo json_encode([
            'success' => true,
            'message' => 'API fonctionnelle',
            'database' => 'Connectée',
            'timestamp' => date('Y-m-d H:i:s'),
            'endpoints' => [
                'test_register' => 'POST /?action=register',
                'real_register' => 'POST /register.php',
                'login' => 'POST /login.php'
            ]
        ]);
    }
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'error' => $e->getMessage(),
        'file' => __FILE__
    ]);
}
