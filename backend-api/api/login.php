<?php
require_once 'config.php';

// Debug: Log des données reçues
error_log("=== LOGIN DEBUG ===");
error_log("Method: " . $_SERVER['REQUEST_METHOD']);
error_log("Content-Type: " . ($_SERVER['CONTENT_TYPE'] ?? 'non défini'));
error_log("Raw input: " . file_get_contents('php://input'));

try {
    // Récupérer les données JSON
    $input = json_decode(file_get_contents('php://input'), true);
    
    error_log("Parsed JSON: " . print_r($input, true));
    
    if (!$input) {
        throw new Exception('Données JSON invalides');
    }    // Validation des champs requis
    if (empty($input['email']) || empty($input['password'])) {
        throw new Exception('Email et mot de passe requis');
    }

    $email = trim($input['email']);
    $password = $input['password'];

    // Validation de l'email
    if (!isValidEmail($email)) {
        throw new Exception('Format d\'email invalide');
    }

    // Connexion à la base de données
    $pdo = getDatabaseConnection();

    // Rechercher l'utilisateur
    $stmt = $pdo->prepare("
        SELECT id, email, password, full_name, phone, 
               is_verified, is_premium, preferences,
               created_at, updated_at
        FROM users 
        WHERE email = ?
    ");
    $stmt->execute([$email]);
    $user = $stmt->fetch(PDO::FETCH_ASSOC);

    if (!$user) {
        throw new Exception('Email ou mot de passe incorrect');
    }

    // Vérifier le mot de passe
    if (!password_verify($password, $user['password'])) {
        throw new Exception('Email ou mot de passe incorrect');
    }

    // Extraire prénom et nom
    $nameParts = explode(' ', $user['full_name'], 2);
    $firstName = $nameParts[0];
    $lastName = isset($nameParts[1]) ? $nameParts[1] : '';

    // Décoder les préférences
    $preferences = json_decode($user['preferences'] ?: '[]', true);

    // Réponse de succès
    echo json_encode([
        'success' => true,
        'message' => 'Connexion réussie',
        'user' => [
            'id' => $user['id'],
            'email' => $user['email'],
            'firstName' => $firstName,
            'lastName' => $lastName,
            'phone' => $user['phone'] ?: '',
            'isPremium' => (bool)$user['is_premium'],
            'isVerified' => (bool)$user['is_verified'],
            'preferences' => $preferences,
            'createdAt' => $user['created_at'],
            'updatedAt' => $user['updated_at']
        ]
    ]);
} catch (Exception $e) {
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'message' => $e->getMessage()
    ]);
} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => 'Erreur de base de données'
    ]);
}
