<?php
// api/health.php - Endpoint pour vérifier si l'API est en ligne
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: GET");

include_once '../config/database.php';

$database = new Database();
$db = $database->getConnection();

if ($db) {
    http_response_code(200);
    echo json_encode(array(
        "status" => "OK",
        "message" => "API is online and database connection is working",
        "timestamp" => date('Y-m-d H:i:s'),
        "version" => "1.0.0"
    ));
} else {
    http_response_code(503);
    echo json_encode(array(
        "status" => "ERROR",
        "message" => "Database connection failed",
        "timestamp" => date('Y-m-d H:i:s')
    ));
}
