import 'package:flutter/material.dart';
import 'package:quiz_app_ar/models/user_model.dart';
import 'package:quiz_app_ar/screens/add_question_screen.dart';
import 'package:quiz_app_ar/screens/reports_screen.dart';
import 'package:quiz_app_ar/screens/manage_admins_screen.dart';
import 'package:quiz_app_ar/screens/approve_users_screen.dart';
import 'package:quiz_app_ar/screens/questions_list_screen.dart';
import 'package:quiz_app_ar/services/auth_service.dart';

class AdminDashboard extends StatelessWidget {
  final User admin;

  const AdminDashboard({super.key, required this.admin});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة تحكم الأدمن'),
        backgroundColor: Colors.deepPurple,
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
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: _buildDashboardCard(
                      context,
                      title: 'إضافة سؤال',
                      icon: Icons.add_circle,
                      color: Colors.green,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AddQuestionScreen(admin: admin),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildDashboardCard(
                      context,
                      title: 'التقارير',
                      icon: Icons.assessment,
                      color: Colors.orange,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ReportsScreen(),
                          ),
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
                    child: _buildDashboardCard(
                      context,
                      title: 'إدارة الأسئلة',
                      icon: Icons.list_alt,
                      color: Colors.blue,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const QuestionsListScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildDashboardCard(
                      context,
                      title: 'موافقة المستخدمين',
                      icon: Icons.person_add_alt_1,
                      color: Colors.teal,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ApproveUsersScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            if (admin.isSuperAdmin) ...[
              const SizedBox(height: 16),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: _buildDashboardCard(
                        context,
                        title: 'إدارة الأدمنز',
                        icon: Icons.admin_panel_settings,
                        color: Colors.purple,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ManageAdminsScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(child: Container()),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [color.withValues(alpha: 0.7), color],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: Colors.white),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
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
