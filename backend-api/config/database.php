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
                "mysql:host=" . $this->host . ";dbname=" . $this->db_name,
                $this->username,
                $this->password,
                [
                    PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
                    PDO::MYSQL_ATTR_INIT_COMMAND => "SET NAMES utf8"
                ]
            );
        } catch (PDOException $exception) {
            echo "Erreur de connexion: " . $exception->getMessage();
        }

        return $this->conn;
    }
}
