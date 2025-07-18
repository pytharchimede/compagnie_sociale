import 'dart:async';
import 'package:flutter/foundation.dart';
import '../database/database_helper.dart';
import '../services/api_service.dart';

class SyncService extends ChangeNotifier {
  static final SyncService _instance = SyncService._internal();
  factory SyncService() => _instance;
  SyncService._internal();

  final DatabaseHelper _dbHelper = DatabaseHelper();
  final ApiService _apiService = ApiService();

  bool _isOnline = false;
  bool _isSyncing = false;
  DateTime? _lastSyncTime;
  Timer? _syncTimer;

  bool get isOnline => _isOnline;
  bool get isSyncing => _isSyncing;
  DateTime? get lastSyncTime => _lastSyncTime;

  // Initialiser le service de synchronisation
  void initialize() {
    // Vérifier la connectivité toutes les 30 secondes
    _syncTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _checkConnectivityAndSync();
    });

    // Vérification initiale
    _checkConnectivityAndSync();
  }

  // Arrêter le service
  @override
  void dispose() {
    _syncTimer?.cancel();
    super.dispose();
  }

  // Vérifier la connectivité et synchroniser si nécessaire
  Future<void> _checkConnectivityAndSync() async {
    final wasOnline = _isOnline;
    _isOnline = await _apiService.checkConnection();

    if (_isOnline != wasOnline) {
      notifyListeners();
    }

    if (_isOnline && !_isSyncing) {
      await syncPendingData();
    }
  }

  // Synchroniser les données en attente
  Future<void> syncPendingData() async {
    if (_isSyncing || !_isOnline) return;

    _isSyncing = true;
    notifyListeners();

    try {
      final pendingItems = await _dbHelper.getPendingSyncItems();

      for (final item in pendingItems) {
        try {
          await _syncItem(item);
          await _dbHelper.markAsSynced(item['id']);
        } catch (e) {
          debugPrint(
              'Erreur lors de la synchronisation de l\'item ${item['id']}: $e');
          // Continuer avec les autres items même si un échoue
        }
      }

      _lastSyncTime = DateTime.now();
    } catch (e) {
      debugPrint('Erreur lors de la synchronisation: $e');
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  // Synchroniser un item spécifique
  Future<void> _syncItem(Map<String, dynamic> item) async {
    final tableName = item['tableName'] as String;
    final action = item['action'] as String;
    final data = item['data'] as String;

    switch (tableName) {
      case 'users':
        await _syncUser(action, data);
        break;
      case 'companions':
        await _syncCompanion(action, data);
        break;
      case 'bookings':
        await _syncBooking(action, data);
        break;
      case 'messages':
        await _syncMessage(action, data);
        break;
      default:
        debugPrint('Table non supportée pour la synchronisation: $tableName');
    }
  }

  // Synchroniser les utilisateurs
  Future<void> _syncUser(String action, String data) async {
    // La synchronisation des utilisateurs est gérée par AuthService
    // Cette méthode est un placeholder pour des cas spéciaux
  }

  // Synchroniser les compagnons
  Future<void> _syncCompanion(String action, String data) async {
    // TODO: Implémenter la synchronisation des compagnons
    // Cela dépendra de votre API et des besoins spécifiques
  }

  // Synchroniser les réservations
  Future<void> _syncBooking(String action, String data) async {
    // TODO: Implémenter la synchronisation des réservations
  }

  // Synchroniser les messages
  Future<void> _syncMessage(String action, String data) async {
    // TODO: Implémenter la synchronisation des messages
  }

  // Forcer une synchronisation
  Future<void> forcSync() async {
    if (!_isOnline) {
      await _checkConnectivityAndSync();
    }

    if (_isOnline) {
      await syncPendingData();
    }
  }

  // Ajouter un item à la queue de synchronisation
  Future<void> addToSyncQueue(String tableName, String recordId, String action,
      Map<String, dynamic> data) async {
    await _dbHelper.addToSyncQueue(tableName, recordId, action, data);

    // Essayer de synchroniser immédiatement si en ligne
    if (_isOnline && !_isSyncing) {
      await syncPendingData();
    }
  }

  // Obtenir le statut de synchronisation
  Map<String, dynamic> getSyncStatus() {
    return {
      'isOnline': _isOnline,
      'isSyncing': _isSyncing,
      'lastSyncTime': _lastSyncTime?.toIso8601String(),
      'pendingItemsCount':
          0, // TODO: Implémenter le comptage des items en attente
    };
  }
}
