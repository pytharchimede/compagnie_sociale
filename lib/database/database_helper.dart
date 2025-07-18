import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user.dart';
import '../models/companion.dart';
import '../models/booking.dart';
import '../models/message.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  factory DatabaseHelper() => _instance;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'compagnie_sociale.db');
    return await openDatabase(
      path,
      version: 2, // Incrémenté pour forcer la migration
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Table utilisateurs avec toutes les colonnes nécessaires
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        email TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        fullName TEXT NOT NULL,
        phone TEXT,
        avatarUrl TEXT,
        dateOfBirth TEXT,
        gender TEXT,
        location TEXT,
        bio TEXT,
        isVerified INTEGER DEFAULT 0,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        lastLoginAt TEXT,
        isPremium INTEGER DEFAULT 0,
        totalBookings INTEGER DEFAULT 0,
        averageRating REAL DEFAULT 0.0,
        totalSavings REAL DEFAULT 0.0,
        preferences TEXT DEFAULT '[]'
      )
    ''');

    // Table compagnons
    await db.execute('''
      CREATE TABLE companions (
        id TEXT PRIMARY KEY,
        userId TEXT NOT NULL,
        services TEXT NOT NULL,
        hourlyRate REAL NOT NULL,
        rating REAL DEFAULT 0.0,
        totalReviews INTEGER DEFAULT 0,
        isAvailable INTEGER DEFAULT 1,
        description TEXT,
        languages TEXT,
        experience TEXT,
        certifications TEXT,
        portfolioImages TEXT,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        FOREIGN KEY (userId) REFERENCES users (id)
      )
    ''');

    // Table réservations
    await db.execute('''
      CREATE TABLE bookings (
        id TEXT PRIMARY KEY,
        clientId TEXT NOT NULL,
        companionId TEXT NOT NULL,
        serviceType TEXT NOT NULL,
        startDateTime TEXT NOT NULL,
        endDateTime TEXT NOT NULL,
        status TEXT NOT NULL,
        totalAmount REAL NOT NULL,
        paymentStatus TEXT NOT NULL,
        paymentMethod TEXT,
        location TEXT,
        notes TEXT,
        rating REAL,
        review TEXT,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        FOREIGN KEY (clientId) REFERENCES users (id),
        FOREIGN KEY (companionId) REFERENCES companions (id)
      )
    ''');

    // Table messages
    await db.execute('''
      CREATE TABLE messages (
        id TEXT PRIMARY KEY,
        senderId TEXT NOT NULL,
        receiverId TEXT NOT NULL,
        bookingId TEXT,
        content TEXT NOT NULL,
        messageType TEXT DEFAULT 'text',
        isRead INTEGER DEFAULT 0,
        createdAt TEXT NOT NULL,
        FOREIGN KEY (senderId) REFERENCES users (id),
        FOREIGN KEY (receiverId) REFERENCES users (id),
        FOREIGN KEY (bookingId) REFERENCES bookings (id)
      )
    ''');

    // Table pour la synchronisation
    await db.execute('''
      CREATE TABLE sync_queue (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        tableName TEXT NOT NULL,
        recordId TEXT NOT NULL,
        action TEXT NOT NULL,
        data TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        synced INTEGER DEFAULT 0
      )
    ''');

    // Index pour optimiser les requêtes
    await db.execute('CREATE INDEX idx_users_email ON users(email)');
    await db
        .execute('CREATE INDEX idx_companions_user_id ON companions(userId)');
    await db
        .execute('CREATE INDEX idx_bookings_client_id ON bookings(clientId)');
    await db.execute(
        'CREATE INDEX idx_bookings_companion_id ON bookings(companionId)');
    await db.execute(
        'CREATE INDEX idx_messages_sender_receiver ON messages(senderId, receiverId)');
    await db
        .execute('CREATE INDEX idx_sync_queue_synced ON sync_queue(synced)');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Migration vers la version 2 : ajouter les colonnes manquantes à la table users
      try {
        await db.execute(
            'ALTER TABLE users ADD COLUMN isPremium INTEGER DEFAULT 0');
        await db.execute(
            'ALTER TABLE users ADD COLUMN totalBookings INTEGER DEFAULT 0');
        await db.execute(
            'ALTER TABLE users ADD COLUMN averageRating REAL DEFAULT 0.0');
        await db.execute(
            'ALTER TABLE users ADD COLUMN totalSavings REAL DEFAULT 0.0');
        await db.execute(
            'ALTER TABLE users ADD COLUMN preferences TEXT DEFAULT \'[]\'');
        print('Database migration to version 2 completed successfully');
      } catch (e) {
        // Si les colonnes existent déjà, ignorer l'erreur
        print('Migration warning: $e');
      }
    }
  }

  // Méthodes pour les utilisateurs
  Future<int> insertUser(User user) async {
    final db = await database;
    return await db.insert('users', user.toJson());
  }

  Future<User?> getUserByEmail(String email) async {
    final db = await database;
    final maps = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );

    if (maps.isNotEmpty) {
      return User.fromJson(maps.first);
    }
    return null;
  }

  Future<User?> getUserById(String id) async {
    final db = await database;
    final maps = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return User.fromJson(maps.first);
    }
    return null;
  }

  Future<int> updateUser(User user) async {
    final db = await database;
    return await db.update(
      'users',
      user.toJson(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  Future<int> deleteUser(String id) async {
    final db = await database;
    return await db.delete(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Méthodes pour les compagnons
  Future<int> insertCompanion(Companion companion) async {
    final db = await database;
    return await db.insert('companions', companion.toJson());
  }

  Future<List<Companion>> getAllCompanions() async {
    final db = await database;
    final maps = await db.query('companions');
    return List.generate(maps.length, (i) => Companion.fromJson(maps[i]));
  }

  Future<List<Companion>> searchCompanions(String query) async {
    final db = await database;
    final maps = await db.query(
      'companions',
      where: 'services LIKE ? OR description LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
    );
    return List.generate(maps.length, (i) => Companion.fromJson(maps[i]));
  }

  // Méthodes pour les réservations
  Future<int> insertBooking(Booking booking) async {
    final db = await database;
    return await db.insert('bookings', booking.toJson());
  }

  Future<List<Booking>> getUserBookings(String userId) async {
    final db = await database;
    final maps = await db.query(
      'bookings',
      where: 'clientId = ? OR companionId = ?',
      whereArgs: [userId, userId],
      orderBy: 'createdAt DESC',
    );
    return List.generate(maps.length, (i) => Booking.fromJson(maps[i]));
  }

  // Méthodes pour les messages
  Future<int> insertMessage(Message message) async {
    final db = await database;
    return await db.insert('messages', message.toJson());
  }

  Future<List<Message>> getConversation(String userId1, String userId2) async {
    final db = await database;
    final maps = await db.query(
      'messages',
      where:
          '(senderId = ? AND receiverId = ?) OR (senderId = ? AND receiverId = ?)',
      whereArgs: [userId1, userId2, userId2, userId1],
      orderBy: 'createdAt ASC',
    );
    return List.generate(maps.length, (i) => Message.fromJson(maps[i]));
  }

  // Méthodes pour la synchronisation
  Future<int> addToSyncQueue(String tableName, String recordId, String action,
      Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert('sync_queue', {
      'tableName': tableName,
      'recordId': recordId,
      'action': action,
      'data': data.toString(),
      'createdAt': DateTime.now().toIso8601String(),
      'synced': 0,
    });
  }

  Future<List<Map<String, dynamic>>> getPendingSyncItems() async {
    final db = await database;
    return await db.query(
      'sync_queue',
      where: 'synced = ?',
      whereArgs: [0],
      orderBy: 'createdAt ASC',
    );
  }

  Future<int> markAsSynced(int syncId) async {
    final db = await database;
    return await db.update(
      'sync_queue',
      {'synced': 1},
      where: 'id = ?',
      whereArgs: [syncId],
    );
  }

  // Méthode pour nettoyer la base de données
  Future<void> clearAllData() async {
    final db = await database;
    await db.delete('users');
    await db.delete('companions');
    await db.delete('bookings');
    await db.delete('messages');
    await db.delete('sync_queue');
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
