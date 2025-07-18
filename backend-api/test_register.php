<?php
// Test script pour l'inscription
// À exécuter depuis le navigateur : http://localhost/votre-projet/backend-api/test_register.php

// Données de test
$test_data = array(
    "email" => "test" . rand(1000, 9999) . "@example.com",
    "password" => "password123",
    "fullName" => "Test User",
    "phone" => "+225 01 02 03 04 05",
    "isPremium" => false
);

echo "<h1>Test d'inscription API</h1>";
echo "<h2>Données envoyées :</h2>";
echo "<pre>" . json_encode($test_data, JSON_PRETTY_PRINT) . "</pre>";

// Simulation d'un appel POST à l'API d'inscription
$url = 'http://localhost' . dirname($_SERVER['REQUEST_URI']) . '/api/auth/register.php';

$options = array(
    'http' => array(
        'header'  => "Content-Type: application/json\r\n",
        'method'  => 'POST',
        'content' => json_encode($test_data)
    )
);

$context  = stream_context_create($options);
$result = file_get_contents($url, false, $context);

echo "<h2>Réponse de l'API :</h2>";
if ($result === FALSE) {
    echo "<p style='color: red;'>Erreur lors de l'appel à l'API</p>";
} else {
    $response = json_decode($result, true);
    if ($response) {
        echo "<pre>" . json_encode($response, JSON_PRETTY_PRINT) . "</pre>";

        if (isset($response['user'])) {
            echo "<p style='color: green;'>✅ Inscription réussie !</p>";
            if (isset($response['user']['isPremium'])) {
                echo "<p style='color: green;'>✅ isPremium est présent dans la réponse</p>";
            } else {
                echo "<p style='color: red;'>❌ isPremium manquant dans la réponse</p>";
            }
        } else {
            echo "<p style='color: red;'>❌ Erreur d'inscription</p>";
        }
    } else {
        echo "<p style='color: red;'>Réponse JSON invalide</p>";
        echo "<pre>" . htmlspecialchars($result) . "</pre>";
    }
}

// Test de la structure de la base de données
echo "<h2>Test de la structure de la base de données :</h2>";

try {
    require_once 'config/database.php';
    $database = new Database();
    $db = $database->getConnection();

    // Vérifier que la table users a bien la colonne is_premium
    $query = "DESCRIBE users";
    $stmt = $db->prepare($query);
    $stmt->execute();

    $columns = $stmt->fetchAll(PDO::FETCH_ASSOC);
    $has_is_premium = false;

    echo "<h3>Colonnes de la table users :</h3>";
    echo "<ul>";
    foreach ($columns as $column) {
        echo "<li>" . $column['Field'] . " (" . $column['Type'] . ")</li>";
        if ($column['Field'] === 'is_premium') {
            $has_is_premium = true;
        }
    }
    echo "</ul>";

    if ($has_is_premium) {
        echo "<p style='color: green;'>✅ La colonne is_premium existe dans la base de données</p>";
    } else {
        echo "<p style='color: red;'>❌ La colonne is_premium n'existe pas dans la base de données</p>";
        echo "<p>Exécutez ce SQL pour l'ajouter :</p>";
        echo "<code>ALTER TABLE users ADD COLUMN is_premium BOOLEAN DEFAULT FALSE;</code>";
    }
} catch (Exception $e) {
    echo "<p style='color: red;'>Erreur de connexion à la base de données : " . $e->getMessage() . "</p>";
}
