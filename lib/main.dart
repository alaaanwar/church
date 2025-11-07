import 'package:flutter/material.dart';
import 'package:quiz_app_ar/home_screen.dart';
import 'package:quiz_app_ar/screens/login_screen.dart';
import 'package:quiz_app_ar/screens/register_screen.dart';
import 'package:quiz_app_ar/services/auth_service.dart';
import 'package:quiz_app_ar/models/user_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AuthService.ensurePrimaryAdminSeeded();
  runApp(const QuizApp());
}

class QuizApp extends StatelessWidget {
  const QuizApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'التطبيق الروحي',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: FutureBuilder<User?>(
        future: AuthService.getCurrentUser(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          
          final user = snapshot.data;
          if (user == null) {
            return const LoginScreen();
          }
          
          return HomeScreen(user: user);
        },
      ),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
      },
    );
  }
}
