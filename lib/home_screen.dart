import 'package:flutter/material.dart';
import 'package:quiz_app_ar/quiz_screen.dart';
import 'package:quiz_app_ar/models/user_model.dart';
import 'package:quiz_app_ar/screens/admin_dashboard.dart';
import 'package:quiz_app_ar/services/auth_service.dart';

class HomeScreen extends StatelessWidget {
  final User user;

  const HomeScreen({super.key, required this.user});

  // تمت إزالة تفعيل الأدمن بالكود من الواجهة الرئيسية، التفعيل الآن عبر لوحة التحكم فقط
  void _noop() {}

  @override
  Widget build(BuildContext context) {
    // إذا كان المستخدم أدمن، اعرض لوحة التحكم
    if (user.isAdmin) {
      return AdminDashboard(admin: user);
    }

    // المستخدم العادي: اعرض الشاشة الرئيسية
    return Scaffold(
      appBar: AppBar(
        title: Text('مرحباً، ${user.name}'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await AuthService.logout();
              if (!context.mounted) return;
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: _buildCard(
                      context,
                      title: 'خلوة',
                      icon: Icons.auto_stories,
                      color: Colors.purple,
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('خلوة - قريباً')),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildCard(
                      context,
                      title: 'آيات',
                      icon: Icons.book,
                      color: Colors.blue,
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('آيات - قريباً')),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: _buildCard(
                      context,
                      title: 'اختبار',
                      icon: Icons.quiz,
                      color: Colors.green,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => QuizScreen(user: user),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildCard(
                      context,
                      title: 'مهام',
                      icon: Icons.task_alt,
                      color: Colors.orange,
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('مهام - قريباً')),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [color.withValues(alpha: 0.7), color],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: Colors.white),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
