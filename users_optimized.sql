-- Structure optimisée de la table users pour Compagnie Sociale CI
-- Version ajustée basée sur votre export tpecloud

-- Suppression de la table existante si elle existe
DROP TABLE IF EXISTS `users`;

-- Création de la table users optimisée
CREATE TABLE `users` (
  `id` varchar(36) NOT NULL,
  `email` varchar(255) NOT NULL,
  `password` varchar(255) NOT NULL,
  `full_name` varchar(255) NOT NULL,
  `phone` varchar(20) DEFAULT NULL,
  `avatar_url` text DEFAULT NULL,
  `date_of_birth` date DEFAULT NULL,
  `gender` enum('male','female','other') DEFAULT NULL,
  `location` varchar(255) DEFAULT NULL,
  `bio` text DEFAULT NULL,
  `is_verified` tinyint(1) DEFAULT 0,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `last_login_at` timestamp NULL DEFAULT NULL,
  `is_premium` tinyint(1) DEFAULT 0,
  `total_bookings` int(11) DEFAULT 0,
  `average_rating` decimal(3,2) DEFAULT 0.00,
  `total_savings` decimal(10,2) DEFAULT 0.00,
  `preferences` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`preferences`))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Index pour optimiser les performances
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `email` (`email`),
  ADD KEY `idx_email` (`email`),
  ADD KEY `idx_created_at` (`created_at`),
  ADD KEY `idx_is_premium` (`is_premium`),
  ADD KEY `idx_is_verified` (`is_verified`);

-- Insertion de l'utilisateur administrateur avec un mot de passe sécurisé
INSERT INTO `users` (`id`, `email`, `password`, `full_name`, `phone`, `avatar_url`, `date_of_birth`, `gender`, `location`, `bio`, `is_verified`, `created_at`, `updated_at`, `last_login_at`, `is_premium`, `total_bookings`, `average_rating`, `total_savings`, `preferences`) VALUES
('admin-001', 'admin@compagnie-sociale-ci.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Administrateur Système', '+225 07 07 07 07 07', NULL, NULL, NULL, 'Abidjan, Côte d\'Ivoire', 'Compte administrateur principal du système', 1, '2025-07-18 17:27:31', '2025-07-18 17:27:31', NULL, 1, 0, 0.00, 0.00, '[]');

-- Insertion d'utilisateurs de test pour le développement
INSERT INTO `users` (`id`, `email`, `password`, `full_name`, `phone`, `avatar_url`, `date_of_birth`, `gender`, `location`, `bio`, `is_verified`, `created_at`, `updated_at`, `last_login_at`, `is_premium`, `total_bookings`, `average_rating`, `total_savings`, `preferences`) VALUES
('user-test-001', 'user@test.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Utilisateur Test', '+225 01 02 03 04 05', NULL, '1990-01-15', 'male', 'Abidjan, Plateau', 'Compte de test pour le développement', 1, '2025-07-18 18:00:00', '2025-07-18 18:00:00', NULL, 0, 5, 4.50, 25000.00, '["shopping", "entertainment"]'),
('user-premium-001', 'premium@test.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Utilisateur Premium', '+225 05 06 07 08 09', NULL, '1985-05-20', 'female', 'Abidjan, Cocody', 'Compte premium de test', 1, '2025-07-18 18:00:00', '2025-07-18 18:00:00', NULL, 1, 12, 4.80, 75000.00, '["travel", "business", "lifestyle"]');

COMMIT;
