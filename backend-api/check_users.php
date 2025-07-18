<?php

/**
 * Script de vérification des utilisateurs en base de données
 * Permet de voir tous les utilisateurs créés récemment
 */

header('Content-Type: text/html; charset=utf-8');
echo "<h1>🔍 Vérification des utilisateurs - Base MySQL</h1>";

// Configuration
require_once 'config/database.php';

echo "<h2>1. Connexion à la base de données</h2>";

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

echo "<h2>2. Liste des utilisateurs récents (dernières 24h)</h2>";

try {
    $stmt = $db->prepare("
        SELECT id, email, full_name, phone, is_premium, created_at, updated_at 
        FROM users 
        WHERE created_at >= DATE_SUB(NOW(), INTERVAL 24 HOUR)
        ORDER BY created_at DESC
    ");
    $stmt->execute();
    $recent_users = $stmt->fetchAll(PDO::FETCH_ASSOC);

    if (count($recent_users) > 0) {
        echo "<p style='color: green;'>✅ " . count($recent_users) . " utilisateur(s) créé(s) dans les dernières 24h</p>";

        echo "<table border='1' style='border-collapse: collapse; width: 100%;'>";
        echo "<tr style='background-color: #f0f0f0;'>";
        echo "<th>ID</th><th>Email</th><th>Nom</th><th>Téléphone</th><th>Premium</th><th>Créé le</th>";
        echo "</tr>";

        foreach ($recent_users as $user) {
            echo "<tr>";
            echo "<td>" . htmlspecialchars($user['id']) . "</td>";
            echo "<td>" . htmlspecialchars($user['email']) . "</td>";
            echo "<td>" . htmlspecialchars($user['full_name']) . "</td>";
            echo "<td>" . htmlspecialchars($user['phone'] ?? 'N/A') . "</td>";
            echo "<td>" . ($user['is_premium'] ? '✅' : '❌') . "</td>";
            echo "<td>" . $user['created_at'] . "</td>";
            echo "</tr>";
        }
        echo "</table>";
    } else {
        echo "<p style='color: orange;'>⚠️ Aucun utilisateur créé dans les dernières 24h</p>";
    }
} catch (Exception $e) {
    echo "<p style='color: red;'>❌ Erreur lors de la récupération des utilisateurs : " . $e->getMessage() . "</p>";
}

echo "<h2>3. Statistiques générales</h2>";

try {
    // Compter tous les utilisateurs
    $stmt = $db->prepare("SELECT COUNT(*) as total FROM users");
    $stmt->execute();
    $total = $stmt->fetch(PDO::FETCH_ASSOC)['total'];

    // Compter les utilisateurs premium
    $stmt = $db->prepare("SELECT COUNT(*) as premium FROM users WHERE is_premium = 1");
    $stmt->execute();
    $premium = $stmt->fetch(PDO::FETCH_ASSOC)['premium'];

    // Compter les utilisateurs créés aujourd'hui
    $stmt = $db->prepare("SELECT COUNT(*) as today FROM users WHERE DATE(created_at) = CURDATE()");
    $stmt->execute();
    $today = $stmt->fetch(PDO::FETCH_ASSOC)['today'];

    echo "<table border='1' style='border-collapse: collapse;'>";
    echo "<tr><th>Statistique</th><th>Valeur</th></tr>";
    echo "<tr><td>Total utilisateurs</td><td>$total</td></tr>";
    echo "<tr><td>Utilisateurs premium</td><td>$premium</td></tr>";
    echo "<tr><td>Créés aujourd'hui</td><td>$today</td></tr>";
    echo "</table>";
} catch (Exception $e) {
    echo "<p style='color: red;'>❌ Erreur lors du calcul des statistiques : " . $e->getMessage() . "</p>";
}

echo "<h2>4. Recherche par email</h2>";

if (isset($_GET['email']) && !empty($_GET['email'])) {
    $email = $_GET['email'];

    try {
        $stmt = $db->prepare("SELECT * FROM users WHERE email = ?");
        $stmt->execute([$email]);
        $user = $stmt->fetch(PDO::FETCH_ASSOC);

        if ($user) {
            echo "<p style='color: green;'>✅ Utilisateur trouvé :</p>";
            echo "<pre>" . json_encode($user, JSON_PRETTY_PRINT) . "</pre>";
        } else {
            echo "<p style='color: red;'>❌ Aucun utilisateur avec l'email : " . htmlspecialchars($email) . "</p>";
        }
    } catch (Exception $e) {
        echo "<p style='color: red;'>❌ Erreur lors de la recherche : " . $e->getMessage() . "</p>";
    }
}

echo "<form method='get'>";
echo "<p>Rechercher un utilisateur par email :</p>";
echo "<input type='email' name='email' placeholder='email@example.com' value='" . ($_GET['email'] ?? '') . "'>";
echo "<button type='submit'>Rechercher</button>";
echo "</form>";

echo "<h2>5. Derniers utilisateurs créés (limite 10)</h2>";

try {
    $stmt = $db->prepare("
        SELECT id, email, full_name, created_at 
        FROM users 
        ORDER BY created_at DESC 
        LIMIT 10
    ");
    $stmt->execute();
    $latest_users = $stmt->fetchAll(PDO::FETCH_ASSOC);

    if (count($latest_users) > 0) {
        echo "<table border='1' style='border-collapse: collapse; width: 100%;'>";
        echo "<tr style='background-color: #f0f0f0;'>";
        echo "<th>ID</th><th>Email</th><th>Nom</th><th>Créé le</th>";
        echo "</tr>";

        foreach ($latest_users as $user) {
            echo "<tr>";
            echo "<td>" . htmlspecialchars(substr($user['id'], 0, 20)) . "...</td>";
            echo "<td>" . htmlspecialchars($user['email']) . "</td>";
            echo "<td>" . htmlspecialchars($user['full_name']) . "</td>";
            echo "<td>" . $user['created_at'] . "</td>";
            echo "</tr>";
        }
        echo "</table>";
    } else {
        echo "<p style='color: orange;'>⚠️ Aucun utilisateur en base de données</p>";
    }
} catch (Exception $e) {
    echo "<p style='color: red;'>❌ Erreur : " . $e->getMessage() . "</p>";
}

echo "<h2>6. Actions</h2>";
echo "<p><a href='debug_inscription.php'>🔄 Tester inscription</a></p>";
echo "<p><a href='?'>🔄 Rafraîchir cette page</a></p>";
