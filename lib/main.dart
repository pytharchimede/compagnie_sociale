import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'utils/app_theme.dart';
import 'providers/companion_provider.dart';
import 'providers/booking_provider.dart';
import 'providers/user_provider.dart';
import 'providers/auth_provider.dart';
import 'screens/login_screen.dart';
import 'screens/main_screen.dart';

void main() {
  runApp(const CompagnieSocialeCIApp());
}

class CompagnieSocialeCIApp extends StatelessWidget {
  const CompagnieSocialeCIApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CompanionProvider()),
        ChangeNotifierProvider(create: (_) => BookingProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: MaterialApp(
        title: 'Compagnie Sociale CI',
        theme: AppTheme.lightTheme,
        home: const AuthWrapper(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        // Afficher un loader pendant l'initialisation
        if (authProvider.isLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Afficher l'écran principal si connecté, sinon l'écran de connexion
        return authProvider.isLoggedIn
            ? const MainScreen()
            : const LoginScreen();
      },
    );
  }
}
