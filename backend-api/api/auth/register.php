<?php
// api/auth/register.php
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
if (
    !empty($data->email) &&
    !empty($data->password) &&
    !empty($data->fullName)
) {
    // Set user property values
    $user->id = uniqid('user_', true);
    $user->email = $data->email;
    $user->full_name = $data->fullName;
    $user->phone = $data->phone ?? null;
    $user->avatar_url = $data->avatarUrl ?? null;
    $user->date_of_birth = $data->dateOfBirth ?? null;
    $user->gender = $data->gender ?? null;
    $user->location = $data->location ?? null;
    $user->bio = $data->bio ?? null;
    $user->is_premium = $data->isPremium ?? false;
    $user->preferences = $data->preferences ?? [];

    // Vérifier si l'email existe déjà
    if ($user->emailExists()) {
        http_response_code(400);
        echo json_encode(array("message" => "Un compte avec cet email existe déjà."));
        exit();
    }

    // Set password (sera hashé dans la méthode create)
    $user->password = $data->password;

    // Create the user
    if ($user->create()) {
        // Generate JWT token (version simplifiée)
        $token = base64_encode($user->id . ':' . time());

        http_response_code(201);
        echo json_encode(array(
            "message" => "Utilisateur créé avec succès.",
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
                "isVerified" => false,
                "createdAt" => $user->created_at,
                "updatedAt" => $user->updated_at,
                "isPremium" => (bool)$user->is_premium,
                "totalBookings" => 0,
                "averageRating" => 0.0,
                "totalSavings" => 0.0,
                "preferences" => $user->preferences
            ),
            "token" => $token
        ));
    } else {
        http_response_code(503);
        echo json_encode(array("message" => "Impossible de créer l'utilisateur."));
    }
} else {
    http_response_code(400);
    echo json_encode(array("message" => "Données incomplètes."));
}
