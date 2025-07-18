-- Script SQL pour créer la base de données Compagnie Sociale CI
-- À exécuter sur votre MySQL tpecloud

-- Table des utilisateurs
CREATE TABLE users (
    id VARCHAR(36) PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    full_name VARCHAR(255) NOT NULL,
    phone VARCHAR(20),
    avatar_url TEXT,
    date_of_birth DATE,
    gender ENUM('male', 'female', 'other'),
    location VARCHAR(255),
    bio TEXT,
    is_verified BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    last_login_at TIMESTAMP NULL,
    is_premium BOOLEAN DEFAULT FALSE,
    total_bookings INT DEFAULT 0,
    average_rating DECIMAL(3,2) DEFAULT 0.00,
    total_savings DECIMAL(10,2) DEFAULT 0.00,
    preferences JSON,
    INDEX idx_email (email),
    INDEX idx_created_at (created_at)
);

-- Table des compagnons
CREATE TABLE companions (
    id VARCHAR(36) PRIMARY KEY,
    user_id VARCHAR(36) NOT NULL,
    services JSON NOT NULL,
    hourly_rate DECIMAL(10,2) NOT NULL,
    rating DECIMAL(3,2) DEFAULT 0.00,
    total_reviews INT DEFAULT 0,
    is_available BOOLEAN DEFAULT TRUE,
    description TEXT,
    languages JSON,
    experience TEXT,
    certifications JSON,
    portfolio_images JSON,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user_id (user_id),
    INDEX idx_rating (rating),
    INDEX idx_hourly_rate (hourly_rate),
    INDEX idx_is_available (is_available)
);

-- Table des réservations
CREATE TABLE bookings (
    id VARCHAR(36) PRIMARY KEY,
    client_id VARCHAR(36) NOT NULL,
    companion_id VARCHAR(36) NOT NULL,
    service_type VARCHAR(100) NOT NULL,
    start_datetime DATETIME NOT NULL,
    end_datetime DATETIME NOT NULL,
    status ENUM('pending', 'confirmed', 'in_progress', 'completed', 'cancelled') NOT NULL DEFAULT 'pending',
    total_amount DECIMAL(10,2) NOT NULL,
    payment_status ENUM('pending', 'paid', 'failed', 'refunded') NOT NULL DEFAULT 'pending',
    payment_method VARCHAR(50),
    location VARCHAR(255),
    notes TEXT,
    rating DECIMAL(3,2),
    review TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (client_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (companion_id) REFERENCES companions(id) ON DELETE CASCADE,
    INDEX idx_client_id (client_id),
    INDEX idx_companion_id (companion_id),
    INDEX idx_status (status),
    INDEX idx_start_datetime (start_datetime)
);

-- Table des messages
CREATE TABLE messages (
    id VARCHAR(36) PRIMARY KEY,
    sender_id VARCHAR(36) NOT NULL,
    receiver_id VARCHAR(36) NOT NULL,
    booking_id VARCHAR(36),
    content TEXT NOT NULL,
    message_type ENUM('text', 'image', 'file') DEFAULT 'text',
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (sender_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (receiver_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (booking_id) REFERENCES bookings(id) ON DELETE SET NULL,
    INDEX idx_sender_receiver (sender_id, receiver_id),
    INDEX idx_booking_id (booking_id),
    INDEX idx_created_at (created_at)
);

-- Table des catégories de services
CREATE TABLE service_categories (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    icon VARCHAR(50),
    color VARCHAR(7),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Table des avis
CREATE TABLE reviews (
    id VARCHAR(36) PRIMARY KEY,
    booking_id VARCHAR(36) NOT NULL,
    reviewer_id VARCHAR(36) NOT NULL,
    reviewed_id VARCHAR(36) NOT NULL,
    rating DECIMAL(3,2) NOT NULL,
    comment TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (booking_id) REFERENCES bookings(id) ON DELETE CASCADE,
    FOREIGN KEY (reviewer_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (reviewed_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_reviewed_id (reviewed_id),
    INDEX idx_rating (rating)
);

-- Table des notifications
CREATE TABLE notifications (
    id VARCHAR(36) PRIMARY KEY,
    user_id VARCHAR(36) NOT NULL,
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    type ENUM('booking', 'message', 'payment', 'general') NOT NULL,
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user_id (user_id),
    INDEX idx_is_read (is_read)
);

-- Insérer des catégories de services par défaut
INSERT INTO service_categories (name, description, icon, color) VALUES
('Accompagnement Social', 'Services d\'accompagnement pour événements sociaux', 'people', '#FF8C00'),
('Garde d\'Enfants', 'Services de garde et garde d\'enfants', 'child_care', '#4CAF50'),
('Aide Ménagère', 'Services d\'aide ménagère et nettoyage', 'cleaning_services', '#2196F3'),
('Cuisine', 'Services de cuisine et traiteur', 'restaurant', '#FF9800'),
('Transport', 'Services de transport et chauffeur', 'directions_car', '#9C27B0'),
('Soutien Scolaire', 'Aide aux devoirs et soutien scolaire', 'school', '#607D8B'),
('Soins Personnels', 'Services de beauté et soins personnels', 'spa', '#E91E63'),
('Jardinage', 'Services de jardinage et entretien', 'yard', '#4CAF50');

-- Créer un utilisateur admin par défaut (mot de passe: admin123)
INSERT INTO users (id, email, password, full_name, is_verified, created_at, updated_at) VALUES
('admin-001', 'admin@compagnie-sociale-ci.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Administrateur', TRUE, NOW(), NOW());
