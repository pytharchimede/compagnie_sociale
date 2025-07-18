import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../models/companion.dart';
import '../models/booking.dart';
import '../models/message.dart';
import 'auth_service.dart';

class ApiService {
  // IMPORTANT: Remplacez par votre domaine tpecloud
  static const String baseUrl = 'https://fidest.ci/rencontre/backend-api/api';
  // Exemple: 'https://compagnie-sociale.tpecloud.com/api'

  static const Map<String, String> headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Auth endpoints
  Future<AuthResult> registerUser(User user) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: headers,
        body: json.encode(user.toApiJson()),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        final registeredUser = User.fromJson(data['user']);
        return AuthResult.success(registeredUser, data['token']);
      } else {
        final error = json.decode(response.body);
        return AuthResult.error(error['message'] ?? 'Erreur d\'inscription');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  Future<AuthResult> loginUser(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: headers,
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final user = User.fromJson(data['user']);
        return AuthResult.success(user, data['token']);
      } else {
        final error = json.decode(response.body);
        return AuthResult.error(error['message'] ?? 'Erreur de connexion');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  Future<void> updateUser(User user) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/users/${user.id}'),
        headers: await _getAuthHeaders(),
        body: json.encode(user.toApiJson()),
      );

      if (response.statusCode != 200) {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Erreur de mise à jour');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  // Companion endpoints
  Future<List<Companion>> fetchCompanions(
      {String? search, int page = 1, int limit = 20}) async {
    try {
      final queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
        if (search != null && search.isNotEmpty) 'search': search,
      };

      final uri = Uri.parse('$baseUrl/companions')
          .replace(queryParameters: queryParams);
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final companions = data['companions'] as List;
        return companions
            .map((companion) => Companion.fromJson(companion))
            .toList();
      } else {
        throw Exception('Erreur lors du chargement des compagnons');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  Future<Companion> fetchCompanionById(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/companions/$id'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Companion.fromJson(data);
      } else {
        throw Exception('Compagnon non trouvé');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  Future<Companion> createCompanion(Companion companion) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/companions'),
        headers: await _getAuthHeaders(),
        body: json.encode(companion.toJson()),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return Companion.fromJson(data);
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Erreur de création');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  // Booking endpoints
  Future<Booking> createBooking(Booking booking) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/bookings'),
        headers: await _getAuthHeaders(),
        body: json.encode(booking.toJson()),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return Booking.fromJson(data);
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Erreur de réservation');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  Future<List<Booking>> fetchUserBookings(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/$userId/bookings'),
        headers: await _getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final bookings = data['bookings'] as List;
        return bookings.map((booking) => Booking.fromJson(booking)).toList();
      } else {
        throw Exception('Erreur lors du chargement des réservations');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  Future<Booking> updateBookingStatus(String bookingId, String status) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/bookings/$bookingId'),
        headers: await _getAuthHeaders(),
        body: json.encode({'status': status}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Booking.fromJson(data);
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Erreur de mise à jour');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  // Message endpoints
  Future<List<Message>> fetchConversation(
      String userId1, String userId2) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/messages/conversation/$userId1/$userId2'),
        headers: await _getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final messages = data['messages'] as List;
        return messages.map((message) => Message.fromJson(message)).toList();
      } else {
        throw Exception('Erreur lors du chargement des messages');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  Future<Message> sendMessage(Message message) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/messages'),
        headers: await _getAuthHeaders(),
        body: json.encode(message.toJson()),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return Message.fromJson(data);
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Erreur d\'envoi');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  // Upload endpoints
  Future<String> uploadImage(String filePath) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/upload/image'),
      );

      request.headers.addAll(await _getAuthHeaders());
      request.files.add(await http.MultipartFile.fromPath('image', filePath));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['url'];
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Erreur d\'upload');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  // Search endpoints
  Future<Map<String, dynamic>> search({
    String? query,
    String? category,
    String? location,
    double? maxPrice,
    double? minRating,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
        if (query != null && query.isNotEmpty) 'q': query,
        if (category != null && category.isNotEmpty) 'category': category,
        if (location != null && location.isNotEmpty) 'location': location,
        if (maxPrice != null) 'maxPrice': maxPrice.toString(),
        if (minRating != null) 'minRating': minRating.toString(),
      };

      final uri =
          Uri.parse('$baseUrl/search').replace(queryParameters: queryParams);
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Erreur de recherche');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  // Private helper methods
  Future<Map<String, String>> _getAuthHeaders() async {
    final authHeaders = Map<String, String>.from(headers);

    // Récupérer le token depuis SharedPreferences
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token != null && token.isNotEmpty) {
        authHeaders['Authorization'] = 'Bearer $token';
      }
    } catch (e) {
      print('Erreur lors de la récupération du token: $e');
    }

    return authHeaders;
  }

  // Health check
  Future<bool> checkConnection() async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/health'),
            headers: headers,
          )
          .timeout(const Duration(seconds: 5));

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
