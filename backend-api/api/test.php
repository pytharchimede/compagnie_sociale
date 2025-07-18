<?php
require_once 'config.php';

header('Content-Type: application/json');

try {
    // Test de connexion à la base de données
    $pdo = getDatabaseConnection();

    // Test de la table users
    $stmt = $pdo->query("SHOW TABLES LIKE 'users'");
    $tableExists = $stmt->fetch() ? true : false;

    if (!$tableExists) {
        // Créer la table users si elle n'existe pas
        $createTable = "
            CREATE TABLE users (
                id VARCHAR(36) PRIMARY KEY,
                email VARCHAR(255) UNIQUE NOT NULL,
                password VARCHAR(255) NOT NULL,
                full_name VARCHAR(255) NOT NULL,
                phone VARCHAR(20),
                is_verified TINYINT(1) DEFAULT 0,
                is_premium TINYINT(1) DEFAULT 0,
                preferences TEXT,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
            )
        ";

        $pdo->exec($createTable);
        $tableExists = true;
    }

    // Compter les utilisateurs
    $stmt = $pdo->query("SELECT COUNT(*) as count FROM users");
    $userCount = $stmt->fetch(PDO::FETCH_ASSOC)['count'];

    echo json_encode([
        'success' => true,
        'message' => 'API fonctionnelle',
        'database' => [
            'connected' => true,
            'users_table_exists' => $tableExists,
            'user_count' => (int)$userCount
        ],
        'endpoints' => [
            'register' => 'POST /register.php',
            'login' => 'POST /login.php',
            'sync_user' => 'POST /sync_user.php'
        ],
        'timestamp' => date('Y-m-d H:i:s')
    ]);
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => 'Erreur API: ' . $e->getMessage(),
        'timestamp' => date('Y-m-d H:i:s')
    ]);
}
