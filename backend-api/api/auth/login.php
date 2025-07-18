<?php
// api/auth/login.php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Max-Age: 3600");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

include_once '../../config/database.php';
include_once '../../models/User.php';

$database = new Database();
$db = $database->getConnection();

$user = new User($db);

// Get posted data
$data = json_decode(file_get_contents("php://input"));

// Make sure data is not empty
if (!empty($data->email) && !empty($data->password)) {

    // Set user property values
    $user->email = $data->email;

    // Check if user exists
    if ($user->readByEmail()) {
        // Verify password
        if (password_verify($data->password, $user->password)) {

            // Update last login
            $user->updateLastLogin();

            // Generate JWT token (version simplifiée)
            $token = base64_encode($user->id . ':' . time());

            http_response_code(200);
            echo json_encode(array(
                "message" => "Connexion réussie.",
                "user" => array(
                    "id" => $user->id,
                    "email" => $user->email,
                    "fullName" => $user->full_name,
                    "phone" => $user->phone,
                    "avatarUrl" => $user->avatar_url,
                    "dateOfBirth" => $user->date_of_birth,
                    "gender" => $user->gender,
                    "location" => $user->location,
                    "bio" => $user->bio,
                    "isVerified" => (bool)$user->is_verified,
                    "createdAt" => $user->created_at,
                    "updatedAt" => $user->updated_at,
                    "lastLoginAt" => $user->last_login_at,
                    "isPremium" => (bool)$user->is_premium,
                    "totalBookings" => (int)$user->total_bookings,
                    "averageRating" => (float)$user->average_rating,
                    "totalSavings" => (float)$user->total_savings,
                    "preferences" => $user->preferences
                ),
                "token" => $token
            ));
        } else {
            http_response_code(401);
            echo json_encode(array("message" => "Mot de passe incorrect."));
        }
    } else {
        http_response_code(401);
        echo json_encode(array("message" => "Utilisateur non trouvé."));
    }
} else {
    http_response_code(400);
    echo json_encode(array("message" => "Email et mot de passe requis."));
}
