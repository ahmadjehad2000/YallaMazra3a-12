import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/villa_provider.dart';
import 'screens/login_screen.dart';
import 'screens/main_app_screen.dart';
import 'screens/moderator_login_screen.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Initialize Firebase and Arabic date formatting
  await Firebase.initializeApp();
  await initializeDateFormatting('ar', null); // 👈 Required for Arabic date support

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AppAuthProvider>(
          create: (_) => AppAuthProvider(),
        ),
        ChangeNotifierProvider<VillaProvider>(
          create: (_) => VillaProvider(),
        ),
      ],
      child: MaterialApp(
        title: 'يلا مزرعة',
        theme: ThemeData(
          scaffoldBackgroundColor: Colors.white,
          primaryColor: const Color(0xFF00C853),
          fontFamily: 'Cairo', // Optional: Use Arabic-friendly font
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            elevation: 0,
            iconTheme: IconThemeData(color: Colors.black),
            titleTextStyle: TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        debugShowCheckedModeBanner: false,
        home: const AuthChecker(),
        routes: {
          '/moderator_login': (context) => const ModeratorLoginScreen(),
        },
      ),
    );
  }
}

class AuthChecker extends StatelessWidget {
  const AuthChecker({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppAuthProvider>(
      builder: (context, authProvider, child) {
        if (authProvider.status == AuthStatus.initial) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (authProvider.isAuthenticated) {
          return MainAppScreen(
            isModerator: authProvider.isModerator,
            isAdmin: authProvider.isAdmin,
          );
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}
