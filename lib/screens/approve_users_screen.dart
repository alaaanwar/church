import 'package:flutter/material.dart';
import 'package:quiz_app_ar/models/user_model.dart';
import 'package:quiz_app_ar/services/auth_service.dart';

class ApproveUsersScreen extends StatefulWidget {
  const ApproveUsersScreen({super.key});

  @override
  State<ApproveUsersScreen> createState() => _ApproveUsersScreenState();
}

class _ApproveUsersScreenState extends State<ApproveUsersScreen> {
  List<User> _pendingUsers = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadPendingUsers();
  }

  Future<void> _loadPendingUsers() async {
    setState(() => _loading = true);
    final users = await AuthService.getPendingUsers();
    setState(() {
      _pendingUsers = users;
      _loading = false;
    });
  }

  Future<void> _approveUser(User user) async {
    await AuthService.approveUser(user.id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('تمت الموافقة على ${user.name}')),
    );
    _loadPendingUsers();
  }

  Future<void> _rejectUser(User user) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تأكيد الرفض'),
        content: Text('هل أنت متأكد من رفض طلب ${user.name}؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('رفض'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await AuthService.rejectUser(user.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تم رفض طلب ${user.name}')),
      );
      _loadPendingUsers();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('موافقة المستخدمين'),
        centerTitle: true,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _pendingUsers.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle_outline, size: 80, color: Colors.green),
                      SizedBox(height: 16),
                      Text(
                        'لا توجد طلبات معلقة',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _pendingUsers.length,
                  itemBuilder: (context, index) {
                    final user = _pendingUsers[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 3,
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        leading: CircleAvatar(
                          backgroundColor: Colors.indigo.shade100,
                          child: Text(
                            user.name[0],
                            style: TextStyle(
                              color: Colors.indigo.shade900,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(
                          user.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text('اسم المستخدم: ${user.username}'),
                            Text('العمر: ${user.age} سنة'),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.check_circle, color: Colors.green),
                              tooltip: 'موافقة',
                              onPressed: () => _approveUser(user),
                            ),
                            IconButton(
                              icon: const Icon(Icons.cancel, color: Colors.red),
                              tooltip: 'رفض',
                              onPressed: () => _rejectUser(user),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
