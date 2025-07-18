<?php

/**
 * Script de debug pour l'inscription - Compagnie Sociale CI
 * Ce script va tester étape par étape l'inscription
 */

header('Content-Type: text/html; charset=utf-8');
echo "<h1>🔍 Debug Inscription - Compagnie Sociale CI</h1>";

// Configuration
require_once '../config/database.php';
require_once '../models/User.php';

echo "<h2>1. Test de connexion à la base de données</h2>";

try {
    $database = new Database();
    $db = $database->getConnection();

    if ($db) {
        echo "<p style='color: green;'>✅ Connexion à la base de données réussie</p>";
    } else {
        echo "<p style='color: red;'>❌ Échec de connexion à la base de données</p>";
        exit;
    }
} catch (Exception $e) {
    echo "<p style='color: red;'>❌ Erreur de connexion : " . $e->getMessage() . "</p>";
    exit;
}

echo "<h2>2. Vérification de la structure de la table users</h2>";

try {
    $stmt = $db->prepare("DESCRIBE users");
    $stmt->execute();
    $columns = $stmt->fetchAll(PDO::FETCH_ASSOC);

    $has_is_premium = false;
    echo "<table border='1' style='border-collapse: collapse;'>";
    echo "<tr><th>Colonne</th><th>Type</th><th>Null</th><th>Default</th></tr>";

    foreach ($columns as $col) {
        echo "<tr>";
        echo "<td>" . $col['Field'] . "</td>";
        echo "<td>" . $col['Type'] . "</td>";
        echo "<td>" . $col['Null'] . "</td>";
        echo "<td>" . $col['Default'] . "</td>";
        echo "</tr>";

        if ($col['Field'] === 'is_premium') {
            $has_is_premium = true;
        }
    }
    echo "</table>";

    if ($has_is_premium) {
        echo "<p style='color: green;'>✅ Colonne is_premium trouvée</p>";
    } else {
        echo "<p style='color: red;'>❌ Colonne is_premium manquante !</p>";
    }
} catch (Exception $e) {
    echo "<p style='color: red;'>❌ Erreur lors de la vérification de structure : " . $e->getMessage() . "</p>";
}

echo "<h2>3. Test de création d'utilisateur</h2>";

// Données de test
$test_data = array(
    "email" => "debug_test_" . time() . "@example.com",
    "password" => "password123",
    "fullName" => "Debug Test User",
    "phone" => "+225 01 02 03 04 05",
    "isPremium" => false
);

echo "<h3>Données d'entrée :</h3>";
echo "<pre>" . json_encode($test_data, JSON_PRETTY_PRINT) . "</pre>";

try {
    // Simuler le processus d'inscription
    $user = new User($db);

    echo "<h3>Étape 3.1 : Attribution des valeurs</h3>";

    $user->id = 'debug-' . uniqid();
    $user->email = $test_data['email'];
    $user->full_name = $test_data['fullName'];
    $user->phone = $test_data['phone'] ?? null;
    $user->avatar_url = $test_data['avatarUrl'] ?? null;
    $user->date_of_birth = $test_data['dateOfBirth'] ?? null;
    $user->gender = $test_data['gender'] ?? null;
    $user->location = $test_data['location'] ?? null;
    $user->bio = $test_data['bio'] ?? null;
    $user->is_premium = $test_data['isPremium'] ?? false;
    $user->preferences = $test_data['preferences'] ?? [];
    $user->password = $test_data['password'];

    echo "<p>✅ Valeurs attribuées :</p>";
    echo "<ul>";
    echo "<li>ID: " . $user->id . "</li>";
    echo "<li>Email: " . $user->email . "</li>";
    echo "<li>Full Name: " . $user->full_name . "</li>";
    echo "<li>Is Premium: " . ($user->is_premium ? 'true' : 'false') . "</li>";
    echo "<li>Phone: " . ($user->phone ?? 'null') . "</li>";
    echo "</ul>";

    echo "<h3>Étape 3.2 : Vérification si email existe</h3>";

    if ($user->emailExists()) {
        echo "<p style='color: orange;'>⚠️ Email existe déjà, test annulé pour éviter les doublons</p>";
    } else {
        echo "<p style='color: green;'>✅ Email disponible</p>";

        echo "<h3>Étape 3.3 : Tentative de création</h3>";

        if ($user->create()) {
            echo "<p style='color: green;'>🎉 SUCCÈS ! Utilisateur créé avec succès</p>";
            echo "<p>ID utilisateur : " . $user->id . "</p>";

            // Test de lecture
            echo "<h3>Étape 3.4 : Vérification de la lecture</h3>";
            $read_user = new User($db);
            $read_user->email = $user->email;

            if ($read_user->readByEmail()) {
                echo "<p style='color: green;'>✅ Utilisateur lu avec succès</p>";
                echo "<p>Is Premium lu : " . ($read_user->is_premium ? 'true' : 'false') . "</p>";

                // Simuler la réponse JSON
                echo "<h3>Étape 3.5 : Simulation de la réponse API</h3>";
                $api_response = array(
                    "message" => "Utilisateur créé avec succès.",
                    "user" => array(
                        "id" => $read_user->id,
                        "email" => $read_user->email,
                        "fullName" => $read_user->full_name,
                        "phone" => $read_user->phone,
                        "avatarUrl" => $read_user->avatar_url,
                        "dateOfBirth" => $read_user->date_of_birth,
                        "gender" => $read_user->gender,
                        "location" => $read_user->location,
                        "bio" => $read_user->bio,
                        "isVerified" => (bool)$read_user->is_verified,
                        "createdAt" => $read_user->created_at,
                        "updatedAt" => $read_user->updated_at,
                        "isPremium" => (bool)$read_user->is_premium,
                        "totalBookings" => (int)$read_user->total_bookings,
                        "averageRating" => (float)$read_user->average_rating,
                        "totalSavings" => (float)$read_user->total_savings,
                        "preferences" => $read_user->preferences
                    ),
                    "token" => "debug_token_123"
                );

                echo "<pre>" . json_encode($api_response, JSON_PRETTY_PRINT) . "</pre>";
            } else {
                echo "<p style='color: red;'>❌ Erreur lors de la lecture de l'utilisateur</p>";
            }

            // Nettoyage
            echo "<h3>Étape 3.6 : Nettoyage</h3>";
            $delete_stmt = $db->prepare("DELETE FROM users WHERE id = ?");
            $delete_stmt->execute([$user->id]);
            echo "<p style='color: blue;'>🧹 Utilisateur de test supprimé</p>";
        } else {
            echo "<p style='color: red;'>❌ ÉCHEC ! Impossible de créer l'utilisateur</p>";

            // Afficher l'erreur SQL
            $error_info = $db->errorInfo();
            if ($error_info[2]) {
                echo "<p style='color: red;'>Erreur SQL : " . $error_info[2] . "</p>";
            }
        }
    }
} catch (Exception $e) {
    echo "<p style='color: red;'>❌ Exception : " . $e->getMessage() . "</p>";
    echo "<pre>" . $e->getTraceAsString() . "</pre>";
}

echo "<h2>4. Résumé du diagnostic</h2>";
echo "<p>Si toutes les étapes sont en ✅ vert, alors l'API d'inscription fonctionne parfaitement.</p>";
echo "<p>Si une étape est en ❌ rouge, c'est là que se trouve le problème.</p>";
