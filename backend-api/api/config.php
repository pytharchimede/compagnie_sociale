<?php
// Configuration de la base de données
define('DB_HOST', 'localhost');
define('DB_NAME', 'compagnie_sociale_ci');
define('DB_USER', 'votre_user_mysql');
define('DB_PASS', 'votre_password_mysql');

// Configuration CORS
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With');
header('Content-Type: application/json; charset=UTF-8');

// Répondre aux requêtes OPTIONS (preflight)
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

// Fonction pour se connecter à la base de données
function getDatabaseConnection()
{
    try {
        $dsn = "mysql:host=" . DB_HOST . ";dbname=" . DB_NAME . ";charset=utf8mb4";
        $options = [
            PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
            PDO::ATTR_EMULATE_PREPARES => false,
        ];
        return new PDO($dsn, DB_USER, DB_PASS, $options);
    } catch (PDOException $e) {
        http_response_code(500);
        echo json_encode([
            'success' => false,
            'message' => 'Erreur de connexion à la base de données'
        ]);
        exit();
    }
}

// Fonction pour générer un UUID
function generateUUID()
{
    return sprintf(
        '%04x%04x-%04x-%04x-%04x-%04x%04x%04x',
        mt_rand(0, 0xffff),
        mt_rand(0, 0xffff),
        mt_rand(0, 0xffff),
        mt_rand(0, 0x0fff) | 0x4000,
        mt_rand(0, 0x3fff) | 0x8000,
        mt_rand(0, 0xffff),
        mt_rand(0, 0xffff),
        mt_rand(0, 0xffff)
    );
}

// Fonction pour valider l'email
function isValidEmail($email)
{
    return filter_var($email, FILTER_VALIDATE_EMAIL) !== false;
}

// Fonction pour hasher le mot de passe
function hashPassword($password)
{
    return password_hash($password, PASSWORD_DEFAULT);
}

// Fonction pour vérifier le mot de passe
function verifyPassword($password, $hash)
{
    return password_verify($password, $hash);
}
