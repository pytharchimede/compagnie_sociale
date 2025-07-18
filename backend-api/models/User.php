<?php
// models/User.php
class User
{
    private $conn;
    private $table_name = "users";

    public $id;
    public $email;
    public $password;
    public $full_name;
    public $phone;
    public $avatar_url;
    public $date_of_birth;
    public $gender;
    public $location;
    public $bio;
    public $is_verified;
    public $created_at;
    public $updated_at;
    public $last_login_at;
    public $is_premium;
    public $total_bookings;
    public $average_rating;
    public $total_savings;
    public $preferences;

    public function __construct($db)
    {
        $this->conn = $db;
    }

    // Créer un utilisateur
    function create()
    {
        $query = "INSERT INTO " . $this->table_name . "
                SET id=:id, email=:email, password=:password, full_name=:full_name,
                    phone=:phone, avatar_url=:avatar_url, date_of_birth=:date_of_birth,
                    gender=:gender, location=:location, bio=:bio, is_premium=:is_premium,
                    preferences=:preferences, created_at=:created_at, updated_at=:updated_at";

        $stmt = $this->conn->prepare($query);

        // Nettoyer les données
        $this->id = htmlspecialchars(strip_tags($this->id));
        $this->email = htmlspecialchars(strip_tags($this->email));
        $this->password = password_hash($this->password, PASSWORD_DEFAULT);
        $this->full_name = htmlspecialchars(strip_tags($this->full_name));
        $this->phone = htmlspecialchars(strip_tags($this->phone));
        $this->avatar_url = htmlspecialchars(strip_tags($this->avatar_url));
        $this->location = htmlspecialchars(strip_tags($this->location));
        $this->bio = htmlspecialchars(strip_tags($this->bio));
        $this->is_premium = $this->is_premium ?? false;
        $this->preferences = json_encode($this->preferences ?? []);
        $this->created_at = date('Y-m-d H:i:s');
        $this->updated_at = date('Y-m-d H:i:s');

        // Bind values
        $stmt->bindParam(":id", $this->id);
        $stmt->bindParam(":email", $this->email);
        $stmt->bindParam(":password", $this->password);
        $stmt->bindParam(":full_name", $this->full_name);
        $stmt->bindParam(":phone", $this->phone);
        $stmt->bindParam(":avatar_url", $this->avatar_url);
        $stmt->bindParam(":date_of_birth", $this->date_of_birth);
        $stmt->bindParam(":gender", $this->gender);
        $stmt->bindParam(":location", $this->location);
        $stmt->bindParam(":bio", $this->bio);
        $stmt->bindParam(":is_premium", $this->is_premium, PDO::PARAM_BOOL);
        $stmt->bindParam(":preferences", $this->preferences);
        $stmt->bindParam(":created_at", $this->created_at);
        $stmt->bindParam(":updated_at", $this->updated_at);

        if ($stmt->execute()) {
            return true;
        }
        return false;
    }

    // Lire un utilisateur par email
    function readByEmail()
    {
        $query = "SELECT * FROM " . $this->table_name . " WHERE email = ? LIMIT 0,1";
        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(1, $this->email);
        $stmt->execute();

        $row = $stmt->fetch(PDO::FETCH_ASSOC);

        if ($row) {
            $this->id = $row['id'];
            $this->email = $row['email'];
            $this->password = $row['password'];
            $this->full_name = $row['full_name'];
            $this->phone = $row['phone'];
            $this->avatar_url = $row['avatar_url'];
            $this->date_of_birth = $row['date_of_birth'];
            $this->gender = $row['gender'];
            $this->location = $row['location'];
            $this->bio = $row['bio'];
            $this->is_verified = $row['is_verified'];
            $this->created_at = $row['created_at'];
            $this->updated_at = $row['updated_at'];
            $this->last_login_at = $row['last_login_at'];
            $this->is_premium = $row['is_premium'];
            $this->total_bookings = $row['total_bookings'];
            $this->average_rating = $row['average_rating'];
            $this->total_savings = $row['total_savings'];
            $this->preferences = json_decode($row['preferences'] ?? '[]', true);
            return true;
        }
        return false;
    }

    // Mettre à jour un utilisateur
    function update()
    {
        $query = "UPDATE " . $this->table_name . "
                SET full_name=:full_name, phone=:phone, avatar_url=:avatar_url,
                    date_of_birth=:date_of_birth, gender=:gender, location=:location,
                    bio=:bio, preferences=:preferences, updated_at=:updated_at
                WHERE id=:id";

        $stmt = $this->conn->prepare($query);

        $this->full_name = htmlspecialchars(strip_tags($this->full_name));
        $this->phone = htmlspecialchars(strip_tags($this->phone));
        $this->avatar_url = htmlspecialchars(strip_tags($this->avatar_url));
        $this->location = htmlspecialchars(strip_tags($this->location));
        $this->bio = htmlspecialchars(strip_tags($this->bio));
        $this->preferences = json_encode($this->preferences ?? []);
        $this->updated_at = date('Y-m-d H:i:s');

        $stmt->bindParam(":full_name", $this->full_name);
        $stmt->bindParam(":phone", $this->phone);
        $stmt->bindParam(":avatar_url", $this->avatar_url);
        $stmt->bindParam(":date_of_birth", $this->date_of_birth);
        $stmt->bindParam(":gender", $this->gender);
        $stmt->bindParam(":location", $this->location);
        $stmt->bindParam(":bio", $this->bio);
        $stmt->bindParam(":preferences", $this->preferences);
        $stmt->bindParam(":updated_at", $this->updated_at);
        $stmt->bindParam(":id", $this->id);

        if ($stmt->execute()) {
            return true;
        }
        return false;
    }

    // Mettre à jour la dernière connexion
    function updateLastLogin()
    {
        $query = "UPDATE " . $this->table_name . " SET last_login_at=:last_login_at WHERE id=:id";
        $stmt = $this->conn->prepare($query);

        $last_login_at = date('Y-m-d H:i:s');
        $stmt->bindParam(":last_login_at", $last_login_at);
        $stmt->bindParam(":id", $this->id);

        return $stmt->execute();
    }

    // Vérifier si l'email existe
    function emailExists()
    {
        $query = "SELECT id FROM " . $this->table_name . " WHERE email = ? LIMIT 0,1";
        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(1, $this->email);
        $stmt->execute();

        if ($stmt->rowCount() > 0) {
            return true;
        }
        return false;
    }
}
