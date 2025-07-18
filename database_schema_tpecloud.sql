-- Schema SQL optimisé pour tpecloud MariaDB - Compagnie Sociale CI
-- Version corrigée pour éviter l'erreur 1005 des contraintes de clés étrangères
-- À exécuter dans phpMyAdmin sur votre hébergement tpecloud

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";

-- Désactiver temporairement les vérifications de clés étrangères
SET FOREIGN_KEY_CHECKS = 0;

-- Supprimer les tables existantes si elles existent (dans l'ordre inverse des dépendances)
DROP TABLE IF EXISTS `reviews`;
DROP TABLE IF EXISTS `notifications`;
DROP TABLE IF EXISTS `messages`;
DROP TABLE IF EXISTS `bookings`;
DROP TABLE IF EXISTS `companions`;
DROP TABLE IF EXISTS `service_categories`;
DROP TABLE IF EXISTS `users`;

-- ====================================================================
-- Table des utilisateurs (table principale - aucune dépendance)
-- ====================================================================
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
  `preferences` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`preferences`)),
  PRIMARY KEY (`id`),
  UNIQUE KEY `email` (`email`),
  KEY `idx_email` (`email`),
  KEY `idx_created_at` (`created_at`),
  KEY `idx_is_premium` (`is_premium`),
  KEY `idx_is_verified` (`is_verified`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ====================================================================
-- Table des catégories de services (indépendante)
-- ====================================================================
CREATE TABLE `service_categories` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `description` text DEFAULT NULL,
  `icon` varchar(50) DEFAULT NULL,
  `color` varchar(7) DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT 1,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ====================================================================
-- Table des compagnons (dépend de users)
-- ====================================================================
CREATE TABLE `companions` (
  `id` varchar(36) NOT NULL,
  `user_id` varchar(36) NOT NULL,
  `services` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL CHECK (json_valid(`services`)),
  `hourly_rate` decimal(10,2) NOT NULL,
  `rating` decimal(3,2) DEFAULT 0.00,
  `total_reviews` int(11) DEFAULT 0,
  `is_available` tinyint(1) DEFAULT 1,
  `description` text DEFAULT NULL,
  `languages` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`languages`)),
  `experience` text DEFAULT NULL,
  `certifications` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`certifications`)),
  `portfolio_images` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`portfolio_images`)),
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_rating` (`rating`),
  KEY `idx_hourly_rate` (`hourly_rate`),
  KEY `idx_is_available` (`is_available`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ====================================================================
-- Table des réservations (dépend de users et companions)
-- ====================================================================
CREATE TABLE `bookings` (
  `id` varchar(36) NOT NULL,
  `client_id` varchar(36) NOT NULL,
  `companion_id` varchar(36) NOT NULL,
  `service_type` varchar(100) NOT NULL,
  `start_datetime` datetime NOT NULL,
  `end_datetime` datetime NOT NULL,
  `status` enum('pending','confirmed','in_progress','completed','cancelled') NOT NULL DEFAULT 'pending',
  `total_amount` decimal(10,2) NOT NULL,
  `payment_status` enum('pending','paid','failed','refunded') NOT NULL DEFAULT 'pending',
  `payment_method` varchar(50) DEFAULT NULL,
  `location` varchar(255) DEFAULT NULL,
  `notes` text DEFAULT NULL,
  `rating` decimal(3,2) DEFAULT NULL,
  `review` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_client_id` (`client_id`),
  KEY `idx_companion_id` (`companion_id`),
  KEY `idx_status` (`status`),
  KEY `idx_start_datetime` (`start_datetime`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ====================================================================
-- Table des messages (dépend de users et bookings)
-- ====================================================================
CREATE TABLE `messages` (
  `id` varchar(36) NOT NULL,
  `sender_id` varchar(36) NOT NULL,
  `receiver_id` varchar(36) NOT NULL,
  `booking_id` varchar(36) DEFAULT NULL,
  `content` text NOT NULL,
  `message_type` enum('text','image','file') DEFAULT 'text',
  `is_read` tinyint(1) DEFAULT 0,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_sender_receiver` (`sender_id`,`receiver_id`),
  KEY `idx_booking_id` (`booking_id`),
  KEY `idx_created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ====================================================================
-- Table des avis (dépend de bookings et users)
-- ====================================================================
CREATE TABLE `reviews` (
  `id` varchar(36) NOT NULL,
  `booking_id` varchar(36) NOT NULL,
  `reviewer_id` varchar(36) NOT NULL,
  `reviewed_id` varchar(36) NOT NULL,
  `rating` decimal(3,2) NOT NULL,
  `comment` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_reviewed_id` (`reviewed_id`),
  KEY `idx_rating` (`rating`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ====================================================================
-- Table des notifications (dépend de users)
-- ====================================================================
CREATE TABLE `notifications` (
  `id` varchar(36) NOT NULL,
  `user_id` varchar(36) NOT NULL,
  `title` varchar(255) NOT NULL,
  `message` text NOT NULL,
  `type` enum('booking','message','payment','general') NOT NULL,
  `is_read` tinyint(1) DEFAULT 0,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_is_read` (`is_read`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ====================================================================
-- Ajout des contraintes de clés étrangères APRÈS création des tables
-- ====================================================================

-- Contraintes pour companions
ALTER TABLE `companions` 
ADD CONSTRAINT `fk_companions_user_id` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

-- Contraintes pour bookings
ALTER TABLE `bookings` 
ADD CONSTRAINT `fk_bookings_client_id` FOREIGN KEY (`client_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
ADD CONSTRAINT `fk_bookings_companion_id` FOREIGN KEY (`companion_id`) REFERENCES `companions` (`id`) ON DELETE CASCADE;

-- Contraintes pour messages
ALTER TABLE `messages` 
ADD CONSTRAINT `fk_messages_sender_id` FOREIGN KEY (`sender_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
ADD CONSTRAINT `fk_messages_receiver_id` FOREIGN KEY (`receiver_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
ADD CONSTRAINT `fk_messages_booking_id` FOREIGN KEY (`booking_id`) REFERENCES `bookings` (`id`) ON DELETE SET NULL;

-- Contraintes pour reviews
ALTER TABLE `reviews` 
ADD CONSTRAINT `fk_reviews_booking_id` FOREIGN KEY (`booking_id`) REFERENCES `bookings` (`id`) ON DELETE CASCADE,
ADD CONSTRAINT `fk_reviews_reviewer_id` FOREIGN KEY (`reviewer_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
ADD CONSTRAINT `fk_reviews_reviewed_id` FOREIGN KEY (`reviewed_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

-- Contraintes pour notifications
ALTER TABLE `notifications` 
ADD CONSTRAINT `fk_notifications_user_id` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

-- Réactiver les vérifications de clés étrangères
SET FOREIGN_KEY_CHECKS = 1;

-- ====================================================================
-- Insertion des données par défaut
-- ====================================================================

-- Insérer des catégories de services par défaut
INSERT INTO `service_categories` (`name`, `description`, `icon`, `color`) VALUES
('Accompagnement Social', 'Services d\'accompagnement pour événements sociaux', 'people', '#FF8C00'),
('Garde d\'Enfants', 'Services de garde et garde d\'enfants', 'child_care', '#4CAF50'),
('Aide Ménagère', 'Services d\'aide ménagère et nettoyage', 'cleaning_services', '#2196F3'),
('Cuisine', 'Services de cuisine et traiteur', 'restaurant', '#FF9800'),
('Transport', 'Services de transport et chauffeur', 'directions_car', '#9C27B0'),
('Soutien Scolaire', 'Aide aux devoirs et soutien scolaire', 'school', '#607D8B'),
('Soins Personnels', 'Services de beauté et soins personnels', 'spa', '#E91E63'),
('Jardinage', 'Services de jardinage et entretien', 'yard', '#4CAF50');

-- Créer un utilisateur admin par défaut (mot de passe: admin123)
INSERT INTO `users` (`id`, `email`, `password`, `full_name`, `phone`, `location`, `bio`, `is_verified`, `is_premium`, `preferences`, `created_at`, `updated_at`) VALUES
('admin-001', 'admin@fidest.ci', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Administrateur Système', '+225 07 07 07 07 07', 'Abidjan, Côte d\'Ivoire', 'Compte administrateur principal du système', 1, 1, '[]', NOW(), NOW());

COMMIT;
