import 'package:flutter/material.dart';
import 'package:quiz_app_ar/models/user_model.dart';
import 'package:quiz_app_ar/services/auth_service.dart';
import 'package:quiz_app_ar/services/answers_service.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  List<User> users = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    final allUsers = await AuthService.getAllUsers();
    setState(() {
      users = allUsers.where((u) => !u.isAdmin).toList();
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('التقارير'),
        backgroundColor: Colors.orange,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : users.isEmpty
              ? const Center(
                  child: Text(
                    'لا يوجد مستخدمين بعد',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    return FutureBuilder<Map<String, int>>(
                      future: AnswersService.getUserStats(user.id),
                      builder: (context, snapshot) {
                        final stats = snapshot.data ?? {'correct': 0, 'wrong': 0, 'total': 0};
                        final correct = stats['correct'] ?? 0;
                        final wrong = stats['wrong'] ?? 0;
                        final total = stats['total'] ?? 0;
                        final percentage = total > 0 ? ((correct / total) * 100).toStringAsFixed(1) : '0.0';

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          elevation: 3,
                          child: ExpansionTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.orange,
                              child: Text(
                                user.name[0].toUpperCase(),
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            title: Text(
                              user.name,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                              textAlign: TextAlign.right,
                            ),
                            subtitle: Text(
                              'العمر: ${user.age} • @${user.username}',
                              textAlign: TextAlign.right,
                            ),
                            children: [
                              const Divider(),
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                      children: [
                                        _buildStatCard('الإجمالي', total, Colors.blue),
                                        _buildStatCard('صحيحة', correct, Colors.green),
                                        _buildStatCard('خاطئة', wrong, Colors.red),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    LinearProgressIndicator(
                                      value: total > 0 ? correct / total : 0,
                                      backgroundColor: Colors.grey[300],
                                      color: Colors.green,
                                      minHeight: 8,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'نسبة النجاح: $percentage%',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
    );
  }

  Widget _buildStatCard(String label, int value, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '$value',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }
}
