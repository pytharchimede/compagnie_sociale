<?php

/**
 * Test simple de la correction User->create()
 * Simule le processus de binding PDO pour identifier le problème
 */

header('Content-Type: text/html; charset=utf-8');
echo "<h1>🔧 Test de la correction User->create()</h1>";

echo "<h2>1. Simulation des problèmes identifiés</h2>";

echo "<h3>Problème 1: PDO::PARAM_BOOL vs PDO::PARAM_INT</h3>";

// Simuler le comportement
$is_premium_bool = false;
$is_premium_int = $is_premium_bool ? 1 : 0;

echo "<p>Valeur boolean: " . var_export($is_premium_bool, true) . " (type: " . gettype($is_premium_bool) . ")</p>";
echo "<p>Valeur entier: " . var_export($is_premium_int, true) . " (type: " . gettype($is_premium_int) . ")</p>";

echo "<h3>Problème 2: Nettoyage des champs NULL</h3>";

// Simuler le nettoyage
$avatar_url_null = null;
$avatar_url_empty = "";

echo "<p>Avant correction - avatar_url NULL:</p>";
echo "<ul>";
echo "<li>Valeur: " . var_export($avatar_url_null, true) . "</li>";
$old_cleaned = htmlspecialchars(strip_tags($avatar_url_null));
echo "<li>Après htmlspecialchars(strip_tags()): '" . $old_cleaned . "'</li>";
echo "</ul>";

echo "<p>Après correction - avatar_url NULL:</p>";
echo "<ul>";
echo "<li>Valeur: " . var_export($avatar_url_null, true) . "</li>";
$new_cleaned = $avatar_url_null ? htmlspecialchars(strip_tags($avatar_url_null)) : null;
echo "<li>Après nettoyage conditionnel: " . var_export($new_cleaned, true) . "</li>";
echo "</ul>";

echo "<h2>2. Analyse de la correction</h2>";

echo "<p style='color: green;'><strong>✅ Corrections appliquées :</strong></p>";
echo "<ul>";
echo "<li>🔄 Changement de <code>PDO::PARAM_BOOL</code> → <code>PDO::PARAM_INT</code></li>";
echo "<li>🔄 Conversion explicite: <code>(\$this->is_premium ?? false) ? 1 : 0</code></li>";
echo "<li>🔄 Nettoyage conditionnel: <code>\$this->phone ? htmlspecialchars(strip_tags(\$this->phone)) : null</code></li>";
echo "</ul>";

echo "<h2>3. Comparaison: Ancien vs Nouveau</h2>";

echo "<table border='1' style='border-collapse: collapse; width: 100%;'>";
echo "<tr><th>Aspect</th><th>Ancien Code</th><th>Nouveau Code</th><th>Impact</th></tr>";

echo "<tr>";
echo "<td>Type is_premium</td>";
echo "<td>PDO::PARAM_BOOL</td>";
echo "<td>PDO::PARAM_INT</td>";
echo "<td style='color: green;'>✅ Compatible MariaDB</td>";
echo "</tr>";

echo "<tr>";
echo "<td>Valeur is_premium</td>";
echo "<td>\$this->is_premium ?? false</td>";
echo "<td>(\$this->is_premium ?? false) ? 1 : 0</td>";
echo "<td style='color: green;'>✅ Entier explicite</td>";
echo "</tr>";

echo "<tr>";
echo "<td>Nettoyage phone</td>";
echo "<td>htmlspecialchars(strip_tags(\$this->phone))</td>";
echo "<td>\$this->phone ? htmlspecialchars(strip_tags(\$this->phone)) : null</td>";
echo "<td style='color: green;'>✅ Évite erreur NULL</td>";
echo "</tr>";

echo "<tr>";
echo "<td>Nettoyage avatar_url</td>";
echo "<td>htmlspecialchars(strip_tags(\$this->avatar_url))</td>";
echo "<td>\$this->avatar_url ? htmlspecialchars(strip_tags(\$this->avatar_url)) : null</td>";
echo "<td style='color: green;'>✅ Évite erreur NULL</td>";
echo "</tr>";

echo "</table>";

echo "<h2>4. Validation théorique</h2>";

echo "<p style='color: blue;'><strong>🧪 Simulation du binding PDO :</strong></p>";

// Simuler le nouveau binding
$simulated_values = [
    'id' => 'debug-test-123',
    'email' => 'test@example.com',
    'password' => password_hash('password123', PASSWORD_DEFAULT),
    'full_name' => 'Test User',
    'phone' => '+225 01 02 03 04 05',
    'avatar_url' => null,
    'date_of_birth' => null,
    'gender' => null,
    'location' => null,
    'bio' => null,
    'is_premium' => 0, // Entier au lieu de boolean
    'preferences' => '[]',
    'created_at' => date('Y-m-d H:i:s'),
    'updated_at' => date('Y-m-d H:i:s')
];

echo "<table border='1' style='border-collapse: collapse; width: 100%;'>";
echo "<tr><th>Paramètre</th><th>Valeur</th><th>Type PHP</th><th>Type PDO</th></tr>";

foreach ($simulated_values as $param => $value) {
    echo "<tr>";
    echo "<td>:" . $param . "</td>";
    echo "<td>" . var_export($value, true) . "</td>";
    echo "<td>" . gettype($value) . "</td>";

    if ($param === 'is_premium') {
        echo "<td style='color: green;'>PDO::PARAM_INT ✅</td>";
    } else {
        echo "<td>PDO::PARAM_STR</td>";
    }
    echo "</tr>";
}

echo "</table>";

echo "<h2>5. Conclusion</h2>";

echo "<p style='color: green; font-size: 18px;'><strong>🎯 La correction devrait résoudre le problème !</strong></p>";

echo "<p><strong>Problèmes résolus :</strong></p>";
echo "<ul>";
echo "<li>✅ Compatibilité MariaDB/MySQL avec PDO::PARAM_INT</li>";
echo "<li>✅ Gestion correcte des valeurs NULL</li>";
echo "<li>✅ Conversion boolean → entier explicite</li>";
echo "<li>✅ Nettoyage conditionnel des champs optionnels</li>";
echo "</ul>";

echo "<p><strong>Pour tester en réel :</strong></p>";
echo "<ol>";
echo "<li>🔄 Relancez debug_inscription.php avec la base de données distante</li>";
echo "<li>🔄 Ou utilisez debug_inscription_local.php avec XAMPP/WAMP</li>";
echo "<li>🎉 La méthode User->create() devrait maintenant fonctionner !</li>";
echo "</ol>";
