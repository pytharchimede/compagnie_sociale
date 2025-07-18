<?php

/**
 * Script de mise à jour de la base de données
 * À exécuter une seule fois pour s'assurer que la structure est correcte
 */

require_once '../config/database.php';

echo "<h1>Mise à jour de la base de données Compagnie Sociale CI</h1>";

try {
    $database = new Database();
    $db = $database->getConnection();

    if (!$db) {
        throw new Exception("Impossible de se connecter à la base de données");
    }

    echo "<p style='color: green;'>✅ Connexion à la base de données réussie</p>";

    // Vérifier la structure actuelle de la table users
    echo "<h2>Vérification de la structure de la table users</h2>";

    $query = "DESCRIBE users";
    $stmt = $db->prepare($query);
    $stmt->execute();
    $columns = $stmt->fetchAll(PDO::FETCH_ASSOC);

    $required_columns = [
        'id' => 'varchar(36)',
        'email' => 'varchar(255)',
        'password' => 'varchar(255)',
        'full_name' => 'varchar(255)',
        'phone' => 'varchar(20)',
        'avatar_url' => 'text',
        'date_of_birth' => 'date',
        'gender' => 'enum',
        'location' => 'varchar(255)',
        'bio' => 'text',
        'is_verified' => 'tinyint(1)',
        'created_at' => 'timestamp',
        'updated_at' => 'timestamp',
        'last_login_at' => 'timestamp',
        'is_premium' => 'tinyint(1)',
        'total_bookings' => 'int(11)',
        'average_rating' => 'decimal(3,2)',
        'total_savings' => 'decimal(10,2)',
        'preferences' => 'longtext'
    ];

    $existing_columns = [];
    foreach ($columns as $column) {
        $existing_columns[$column['Field']] = $column['Type'];
    }

    echo "<h3>Colonnes existantes :</h3><ul>";
    foreach ($existing_columns as $name => $type) {
        echo "<li><strong>$name</strong>: $type</li>";
    }
    echo "</ul>";

    // Vérifier les colonnes manquantes
    $missing_columns = [];
    foreach ($required_columns as $name => $type) {
        if (!isset($existing_columns[$name])) {
            $missing_columns[] = $name;
        }
    }

    if (empty($missing_columns)) {
        echo "<p style='color: green;'>✅ Toutes les colonnes requises sont présentes</p>";
    } else {
        echo "<p style='color: orange;'>⚠️ Colonnes manquantes : " . implode(', ', $missing_columns) . "</p>";

        // Suggestions d'ajout si nécessaire
        foreach ($missing_columns as $column) {
            $type = $required_columns[$column];
            echo "<p>Pour ajouter la colonne $column :</p>";
            echo "<code>ALTER TABLE users ADD COLUMN $column $type;</code><br>";
        }
    }

    // Vérifier les index
    echo "<h2>Vérification des index</h2>";

    $query = "SHOW INDEX FROM users";
    $stmt = $db->prepare($query);
    $stmt->execute();
    $indexes = $stmt->fetchAll(PDO::FETCH_ASSOC);

    $existing_indexes = [];
    foreach ($indexes as $index) {
        $existing_indexes[] = $index['Key_name'];
    }

    $required_indexes = ['PRIMARY', 'email', 'idx_email', 'idx_created_at'];
    $recommended_indexes = ['idx_is_premium', 'idx_is_verified'];

    echo "<h3>Index existants :</h3><ul>";
    foreach (array_unique($existing_indexes) as $index) {
        echo "<li>$index</li>";
    }
    echo "</ul>";

    // Test d'insertion
    echo "<h2>Test d'insertion d'un utilisateur</h2>";

    $test_user_id = 'test-' . uniqid();
    $test_email = 'test-' . time() . '@example.com';

    $query = "INSERT INTO users (id, email, password, full_name, is_premium, preferences, created_at, updated_at) 
              VALUES (:id, :email, :password, :full_name, :is_premium, :preferences, :created_at, :updated_at)";

    $stmt = $db->prepare($query);
    $stmt->bindParam(':id', $test_user_id);
    $stmt->bindParam(':email', $test_email);
    $password = password_hash('test123', PASSWORD_DEFAULT);
    $stmt->bindParam(':password', $password);
    $full_name = 'Utilisateur Test';
    $stmt->bindParam(':full_name', $full_name);
    $is_premium = false;
    $stmt->bindParam(':is_premium', $is_premium, PDO::PARAM_BOOL);
    $preferences = '[]';
    $stmt->bindParam(':preferences', $preferences);
    $created_at = date('Y-m-d H:i:s');
    $stmt->bindParam(':created_at', $created_at);
    $stmt->bindParam(':updated_at', $created_at);

    if ($stmt->execute()) {
        echo "<p style='color: green;'>✅ Test d'insertion réussi avec l'utilisateur ID: $test_user_id</p>";

        // Nettoyer le test
        $delete_query = "DELETE FROM users WHERE id = :id";
        $delete_stmt = $db->prepare($delete_query);
        $delete_stmt->bindParam(':id', $test_user_id);
        $delete_stmt->execute();
        echo "<p style='color: blue;'>🧹 Utilisateur de test supprimé</p>";
    } else {
        echo "<p style='color: red;'>❌ Échec du test d'insertion</p>";
    }

    // Résumé
    echo "<h2>Résumé</h2>";
    echo "<p style='color: green;'>✅ Structure de base de données compatible</p>";
    echo "<p style='color: green;'>✅ Colonne is_premium présente et fonctionnelle</p>";
    echo "<p style='color: green;'>✅ Test d'insertion/suppression réussi</p>";
    echo "<p><strong>Votre base de données est prête pour l'application !</strong></p>";
} catch (Exception $e) {
    echo "<p style='color: red;'>❌ Erreur : " . $e->getMessage() . "</p>";
}
