<?php
require_once 'config.php';

// Debug: Log des données reçues
error_log("=== REGISTER DEBUG ===");
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
    $requiredFields = ['email', 'password', 'firstName', 'lastName'];
    foreach ($requiredFields as $field) {
        if (empty($input[$field])) {
            throw new Exception("Le champ $field est requis");
        }
    }

    $email = trim($input['email']);
    $password = $input['password'];
    $firstName = trim($input['firstName']);
    $lastName = trim($input['lastName']);
    $phone = isset($input['phone']) ? trim($input['phone']) : '';

    // Validation de l'email
    if (!isValidEmail($email)) {
        throw new Exception('Format d\'email invalide');
    }

    // Validation du mot de passe
    if (strlen($password) < 6) {
        throw new Exception('Le mot de passe doit contenir au moins 6 caractères');
    }

    // Connexion à la base de données
    $pdo = getDatabaseConnection();

    // Vérifier si l'email existe déjà
    $stmt = $pdo->prepare("SELECT id FROM users WHERE email = ?");
    $stmt->execute([$email]);

    if ($stmt->fetch()) {
        throw new Exception('Cette adresse email est déjà utilisée');
    }

    // Créer le nouvel utilisateur
    $userId = generateUUID();
    $hashedPassword = hashPassword($password);
    $fullName = $firstName . ' ' . $lastName;

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

    // Réponse de succès
    echo json_encode([
        'success' => true,
        'message' => 'Compte créé avec succès',
        'user' => [
            'id' => $userId,
            'email' => $email,
            'firstName' => $firstName,
            'lastName' => $lastName,
            'phone' => $phone,
            'isPremium' => false
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
