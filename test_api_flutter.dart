import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

void main() async {
  print('🧪 Test de simulation Flutter → API');

  const String baseUrl = 'https://fidest.ci/rencontre/backend-api/api';
  final String testEmail =
      'test_flutter_${DateTime.now().millisecondsSinceEpoch}@example.com';
  const String testPassword = 'flutter123';

  print('\n📧 Credentials de test:');
  print('Email: $testEmail');
  print('Password: $testPassword');

  try {
    // Test 1: Inscription
    print('\n🔄 Test 1: Inscription...');
    final registerResponse = await http.post(
      Uri.parse('$baseUrl/register.php'),
      headers: {
        'Content-Type': 'application/json',
        'User-Agent': 'CompagnieSociale/1.0',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'email': testEmail,
        'password': testPassword,
        'firstName': 'TestFlutter',
        'lastName': 'User',
        'phone': '0123456789',
      }),
    );

    print('Status: ${registerResponse.statusCode}');
    print('Response: ${registerResponse.body}');

    final registerData = jsonDecode(registerResponse.body);

    if (registerResponse.statusCode == 200 && registerData['success'] == true) {
      print('✅ Inscription réussie');

      // Test 2: Connexion immédiate
      print('\n🔄 Test 2: Connexion...');
      final loginResponse = await http.post(
        Uri.parse('$baseUrl/login.php'),
        headers: {
          'Content-Type': 'application/json',
          'User-Agent': 'CompagnieSociale/1.0',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': testEmail,
          'password': testPassword,
        }),
      );

      print('Status: ${loginResponse.statusCode}');
      print('Response: ${loginResponse.body}');

      final loginData = jsonDecode(loginResponse.body);

      if (loginResponse.statusCode == 200 && loginData['success'] == true) {
        print('✅ Connexion réussie');
        print('🎉 TOUS LES TESTS SONT PASSÉS!');
      } else {
        print('❌ Échec de la connexion');
        print('Message: ${loginData['message']}');
      }
    } else {
      print('❌ Échec de l\'inscription');
      print('Message: ${registerData['message']}');
    }
  } catch (e) {
    print('❌ Erreur: $e');
  }

  print('\n📝 Actions recommandées:');
  print('1. Consultez les logs d\'erreur sur fidest.ci');
  print('2. Vérifiez les messages de debug dans les logs');
  print(
      '3. Si la connexion échoue, c\'est un problème de hash de mot de passe');
}
