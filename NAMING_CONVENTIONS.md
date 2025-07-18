# Convention de nommage - Compagnie Sociale CI

## 📋 Tableau de correspondance des champs

| **Base de données MySQL** | **PHP Backend**         | **JSON API Response** | **Flutter/Dart** |
| ------------------------- | ----------------------- | --------------------- | ---------------- |
| `is_premium`              | `$user->is_premium`     | `"isPremium"`         | `isPremium`      |
| `is_verified`             | `$user->is_verified`    | `"isVerified"`        | `isVerified`     |
| `full_name`               | `$user->full_name`      | `"fullName"`          | `fullName`       |
| `avatar_url`              | `$user->avatar_url`     | `"avatarUrl"`         | `avatarUrl`      |
| `date_of_birth`           | `$user->date_of_birth`  | `"dateOfBirth"`       | `dateOfBirth`    |
| `created_at`              | `$user->created_at`     | `"createdAt"`         | `createdAt`      |
| `updated_at`              | `$user->updated_at`     | `"updatedAt"`         | `updatedAt`      |
| `last_login_at`           | `$user->last_login_at`  | `"lastLoginAt"`       | `lastLoginAt`    |
| `total_bookings`          | `$user->total_bookings` | `"totalBookings"`     | `totalBookings`  |
| `average_rating`          | `$user->average_rating` | `"averageRating"`     | `averageRating`  |
| `total_savings`           | `$user->total_savings`  | `"totalSavings"`      | `totalSavings`   |

## ✅ Implémentation actuelle

### 1. **Base de données** (snake_case)

```sql
CREATE TABLE users (
    is_premium tinyint(1) DEFAULT 0,
    is_verified tinyint(1) DEFAULT 0,
    full_name varchar(255) NOT NULL,
    -- etc.
);
```

### 2. **Modèle PHP** (snake_case pour correspondre à la DB)

```php
class User {
    public $is_premium;
    public $is_verified;
    public $full_name;

    // Dans readByEmail()
    $this->is_premium = $row['is_premium'];
}
```

### 3. **API Response** (camelCase pour le frontend)

```php
// Dans register.php et login.php
"isPremium" => (bool)$user->is_premium,
"isVerified" => (bool)$user->is_verified,
"fullName" => $user->full_name,
```

### 4. **Flutter Model** (camelCase)

```dart
class User {
    final bool isPremium;
    final bool isVerified;
    final String fullName;

    // Dans fromJson()
    isPremium: json['isPremium'] ?? false,
}
```

## 🎯 Conclusion

**Le mapping est déjà correct !**

- ✅ Base MySQL utilise `is_premium` (snake_case)
- ✅ PHP utilise `$user->is_premium` (correspondance DB)
- ✅ JSON API retourne `"isPremium"` (camelCase)
- ✅ Flutter attend `isPremium` (camelCase)

**Cette convention est standard et respecte les bonnes pratiques !**

Si l'erreur persiste, elle vient d'ailleurs (permissions DB, connexion, etc.) mais pas du nommage.
