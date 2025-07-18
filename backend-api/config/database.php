<?php
// config/database.php
class Database
{
    private $host = "localhost"; // Remplacez par l'host de votre MySQL tpecloud
    private $db_name = "fidestci_compagnie_sociale"; // Nom de votre base de données
    private $username = "fidestci_ulrich"; // Votre nom d'utilisateur MySQL
    private $password = "@Succes2019"; // Votre mot de passe MySQL
    public $conn;

    public function getConnection()
    {
        $this->conn = null;

        try {
            $this->conn = new PDO(
                "mysql:host=" . $this->host . ";dbname=" . $this->db_name . ";charset=utf8mb4",
                $this->username,
                $this->password,
                [
                    PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
                    PDO::MYSQL_ATTR_INIT_COMMAND => "SET NAMES utf8mb4 COLLATE utf8mb4_unicode_ci",
                    PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
                    PDO::ATTR_EMULATE_PREPARES => false
                ]
            );
        } catch (PDOException $exception) {
            echo "Erreur de connexion: " . $exception->getMessage();
        }

        return $this->conn;
    }
}
