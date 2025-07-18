<?php
require_once 'config.php';

try {
    // Récupérer les données JSON
    $input = json_decode(file_get_contents('php://input'), true);

    if (!$input) {
        throw new Exception('Données JSON invalides');
    }

    // Validation des champs requis pour la synchronisation
    if (empty($input['user'])) {
        throw new Exception('Données utilisateur requises pour la synchronisation');
    }

    $userData = $input['user'];
    $requiredFields = ['id', 'email', 'firstName', 'lastName'];

    foreach ($requiredFields as $field) {
        if (empty($userData[$field])) {
            throw new Exception("Le champ $field est requis");
        }
    }

    $userId = $userData['id'];
    $email = trim($userData['email']);
    $firstName = trim($userData['firstName']);
    $lastName = trim($userData['lastName']);
    $phone = isset($userData['phone']) ? trim($userData['phone']) : '';
    $isPremium = isset($userData['isPremium']) ? (bool)$userData['isPremium'] : false;
    $preferences = isset($userData['preferences']) ? json_encode($userData['preferences']) : '[]';

    // Validation de l'email
    if (!isValidEmail($email)) {
        throw new Exception('Format d\'email invalide');
    }

    // Connexion à la base de données
    $pdo = getDatabaseConnection();

    // Vérifier si l'utilisateur existe déjà
    $stmt = $pdo->prepare("SELECT id, updated_at FROM users WHERE id = ?");
    $stmt->execute([$userId]);
    $existingUser = $stmt->fetch(PDO::FETCH_ASSOC);

    $fullName = $firstName . ' ' . $lastName;

    if ($existingUser) {
        // Mettre à jour l'utilisateur existant
        $stmt = $pdo->prepare("
            UPDATE users SET 
                email = ?, 
                full_name = ?, 
                phone = ?, 
                is_premium = ?, 
                preferences = ?,
                updated_at = NOW()
            WHERE id = ?
        ");

        $stmt->execute([
            $email,
            $fullName,
            $phone,
            $isPremium ? 1 : 0,
            $preferences,
            $userId
        ]);

        $message = 'Utilisateur synchronisé avec succès';
    } else {
        // Créer un nouvel utilisateur (utilisateur créé hors ligne)
        // Mot de passe temporaire pour les comptes synchronisés
        $tempPassword = hashPassword('temp_' . $userId);

        $stmt = $pdo->prepare("
            INSERT INTO users (
                id, email, password, full_name, phone, 
                is_verified, is_premium, preferences, 
                created_at, updated_at
            ) VALUES (?, ?, ?, ?, ?, 0, ?, ?, NOW(), NOW())
        ");

        $stmt->execute([
            $userId,
            $email,
            $tempPassword,
            $fullName,
            $phone,
            $isPremium ? 1 : 0,
            $preferences
        ]);

        $message = 'Nouvel utilisateur synchronisé avec succès';
    }

    // Récupérer les données mises à jour
    $stmt = $pdo->prepare("
        SELECT id, email, full_name, phone, 
               is_verified, is_premium, preferences,
               created_at, updated_at
        FROM users 
        WHERE id = ?
    ");
    $stmt->execute([$userId]);
    $syncedUser = $stmt->fetch(PDO::FETCH_ASSOC);

    // Extraire prénom et nom
    $nameParts = explode(' ', $syncedUser['full_name'], 2);
    $firstName = $nameParts[0];
    $lastName = isset($nameParts[1]) ? $nameParts[1] : '';

    // Décoder les préférences
    $preferences = json_decode($syncedUser['preferences'] ?: '[]', true);

    // Réponse de succès
    echo json_encode([
        'success' => true,
        'message' => $message,
        'user' => [
            'id' => $syncedUser['id'],
            'email' => $syncedUser['email'],
            'firstName' => $firstName,
            'lastName' => $lastName,
            'phone' => $syncedUser['phone'] ?: '',
            'isPremium' => (bool)$syncedUser['is_premium'],
            'isVerified' => (bool)$syncedUser['is_verified'],
            'preferences' => $preferences,
            'createdAt' => $syncedUser['created_at'],
            'updatedAt' => $syncedUser['updated_at']
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
        'message' => 'Erreur de base de données: ' . $e->getMessage()
    ]);
}
