<?php

/**
 * Script pour analyser la méthode User->create()
 * Permet de voir exactement ce qui se passe dans cette méthode
 */

header('Content-Type: text/html; charset=utf-8');
echo "<h1>🔍 Analyse de User->create()</h1>";

require_once 'config/database.php';
require_once 'models/User.php';

echo "<h2>1. Analyse du code source User.php</h2>";

$user_file = file_get_contents('models/User.php');

// Extraire la méthode create()
$start = strpos($user_file, 'function create()');
$end = strpos($user_file, '}', strpos($user_file, 'return', $start));
$create_method = substr($user_file, $start, $end - $start + 1);

echo "<h3>Méthode create() actuelle :</h3>";
echo "<pre style='background: #f0f0f0; padding: 10px; border: 1px solid #ccc;'>";
echo htmlspecialchars($create_method);
echo "</pre>";

echo "<h2>2. Test avec données réelles</h2>";

try {
    $database = new Database();
    $db = $database->getConnection();

    $user = new User($db);

    // Données de test
    $user->id = 'test-analyze-' . uniqid();
    $user->email = 'analyze_test_' . time() . '@example.com';
    $user->password = 'password123';
    $user->full_name = 'Analyze Test User';
    $user->phone = '+225 01 02 03 04 05';
    $user->avatar_url = null;
    $user->date_of_birth = null;
    $user->gender = null;
    $user->location = null;
    $user->bio = null;
    $user->is_premium = false;
    $user->preferences = [];

    echo "<h3>Données préparées :</h3>";
    echo "<table border='1' style='border-collapse: collapse;'>";
    echo "<tr><th>Propriété</th><th>Valeur</th><th>Type</th></tr>";

    $reflection = new ReflectionClass($user);
    $properties = $reflection->getProperties(ReflectionProperty::IS_PUBLIC);

    foreach ($properties as $property) {
        $name = $property->getName();
        $value = $property->getValue($user);
        $type = gettype($value);

        echo "<tr>";
        echo "<td>$name</td>";
        echo "<td>" . (is_null($value) ? 'NULL' : (is_bool($value) ? ($value ? 'true' : 'false') : htmlspecialchars(print_r($value, true)))) . "</td>";
        echo "<td>$type</td>";
        echo "</tr>";
    }
    echo "</table>";

    echo "<h3>Test de la requête SQL :</h3>";

    // Simuler ce que fait la méthode create()
    $expected_query = "INSERT INTO users SET id=:id, email=:email, password=:password, full_name=:full_name,
                    phone=:phone, avatar_url=:avatar_url, date_of_birth=:date_of_birth,
                    gender=:gender, location=:location, bio=:bio, is_premium=:is_premium,
                    preferences=:preferences, created_at=:created_at, updated_at=:updated_at";

    echo "<p><strong>Requête attendue :</strong></p>";
    echo "<pre style='background: #e6f3ff; padding: 10px; border: 1px solid #4CAF50;'>";
    echo htmlspecialchars($expected_query);
    echo "</pre>";

    // Vérifier si la requête peut être préparée
    $stmt = $db->prepare($expected_query);
    if ($stmt) {
        echo "<p style='color: green;'>✅ Requête préparée avec succès</p>";

        // Simuler le binding
        echo "<h3>Simulation du binding des paramètres :</h3>";
        echo "<ul>";

        $bindings = [
            ':id' => $user->id,
            ':email' => $user->email,
            ':password' => password_hash($user->password, PASSWORD_DEFAULT),
            ':full_name' => $user->full_name,
            ':phone' => $user->phone,
            ':avatar_url' => $user->avatar_url,
            ':date_of_birth' => $user->date_of_birth,
            ':gender' => $user->gender,
            ':location' => $user->location,
            ':bio' => $user->bio,
            ':is_premium' => $user->is_premium,
            ':preferences' => json_encode($user->preferences ?? []),
            ':created_at' => date('Y-m-d H:i:s'),
            ':updated_at' => date('Y-m-d H:i:s')
        ];

        foreach ($bindings as $param => $value) {
            $display_value = is_null($value) ? 'NULL' : (is_bool($value) ? ($value ? 'true (1)' : 'false (0)') : (strlen($value) > 50 ? substr($value, 0, 50) . '...' : $value));
            echo "<li><strong>$param</strong>: $display_value (" . gettype($value) . ")</li>";
        }
        echo "</ul>";
    } else {
        echo "<p style='color: red;'>❌ Erreur lors de la préparation de la requête</p>";
        $error = $db->errorInfo();
        echo "<p>Erreur PDO: " . $error[2] . "</p>";
    }
} catch (Exception $e) {
    echo "<p style='color: red;'>❌ Exception : " . $e->getMessage() . "</p>";
    echo "<pre>" . $e->getTraceAsString() . "</pre>";
}

echo "<h2>3. Recommandations</h2>";
echo "<p>Si la requête se prépare bien mais l'insertion échoue, vérifiez :</p>";
echo "<ul>";
echo "<li>La longueur des chaînes (varchar limités)</li>";
echo "<li>Les contraintes de la base de données</li>";
echo "<li>Les valeurs NULL dans des champs NOT NULL</li>";
echo "<li>Le format des dates</li>";
echo "<li>La validation JSON pour preferences</li>";
echo "</ul>";
