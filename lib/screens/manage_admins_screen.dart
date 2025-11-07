import 'package:flutter/material.dart';
import 'package:quiz_app_ar/models/user_model.dart';
import 'package:quiz_app_ar/services/auth_service.dart';
import 'package:quiz_app_ar/screens/user_details_screen.dart';

class ManageAdminsScreen extends StatefulWidget {
  const ManageAdminsScreen({super.key});

  @override
  State<ManageAdminsScreen> createState() => _ManageAdminsScreenState();
}

class _ManageAdminsScreenState extends State<ManageAdminsScreen> {
  List<User> allUsers = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    final users = await AuthService.getAllUsers();
    setState(() {
      allUsers = users;
      loading = false;
    });
  }

  Future<void> _promoteToAdmin(User user) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد', textAlign: TextAlign.right),
        content: Text(
          'هل تريد ترقية ${user.name} إلى أدمن؟',
          textAlign: TextAlign.right,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('تأكيد'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await AuthService.promoteToAdmin(user.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تم ترقية ${user.name} إلى أدمن ✓')),
      );
      _loadUsers();
    }
  }

  Future<void> _deleteUser(User user) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف', textAlign: TextAlign.right),
        content: Text(
          'هل تريد حذف المستخدم ${user.name} نهائياً؟',
          textAlign: TextAlign.right,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('حذف'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await AuthService.deleteUser(user.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تم حذف ${user.name}')),
      );
      _loadUsers();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة الأدمنز'),
        backgroundColor: Colors.purple,
        actions: [
          // زر إعادة التهيئة يظهر فقط إذا المستخدم الحالي هو الأدمن الرئيسي
          IconButton(
            tooltip: 'إعادة ضبط (إبقاء الأدمن فقط)',
            icon: const Icon(Icons.restart_alt),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('تأكيد العملية', textAlign: TextAlign.right),
                  content: const Text(
                    'سيتم حذف جميع المستخدمين والإبقاء على حساب ADMIN فقط. هل أنت متأكد؟',
                    textAlign: TextAlign.right,
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('إلغاء'),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('تأكيد'),
                    ),
                  ],
                ),
              );
              if (confirm == true) {
                await AuthService.resetToOnlyPrimaryAdmin();
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('تمت إعادة الضبط – الحساب المتبقي: ADMIN')),
                );
                await _loadUsers();
              }
            },
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text(
                  'الأدمنز الحاليين',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.right,
                ),
                const SizedBox(height: 12),
                ...allUsers.where((u) => u.isAdmin).map((admin) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      onTap: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => UserDetailsScreen(user: admin),
                          ),
                        );
                        if (result == true) _loadUsers();
                      },
                      leading: CircleAvatar(
                        backgroundColor: admin.isSuperAdmin ? Colors.purple : Colors.deepPurple,
                        child: Text(
                          admin.name[0].toUpperCase(),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      title: Text(admin.name, textAlign: TextAlign.right),
                      subtitle: Text(
                        admin.isSuperAdmin ? 'أدمن رئيسي • @${admin.username}' : 'أدمن • @${admin.username}',
                        textAlign: TextAlign.right,
                      ),
                      trailing: admin.isSuperAdmin
                          ? const Icon(Icons.verified, color: Colors.purple)
                          : IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              tooltip: 'حذف الأدمن',
                              onPressed: () => _deleteUser(admin),
                            ),
                    ),
                  );
                }),
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 12),
                const Text(
                  'المستخدمين العاديين',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.right,
                ),
                const SizedBox(height: 12),
                ...allUsers.where((u) => !u.isAdmin).map((user) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      onTap: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => UserDetailsScreen(user: user),
                          ),
                        );
                        if (result == true) _loadUsers();
                      },
                      leading: CircleAvatar(
                        backgroundColor: Colors.grey,
                        child: Text(
                          user.name[0].toUpperCase(),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      title: Text(user.name, textAlign: TextAlign.right),
                      subtitle: Text(
                        'العمر: ${user.age} • @${user.username}',
                        textAlign: TextAlign.right,
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () => _promoteToAdmin(user),
                            icon: const Icon(Icons.arrow_upward, size: 18),
                            label: const Text('ترقية'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.purple,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            tooltip: 'حذف المستخدم',
                            onPressed: () => _deleteUser(user),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
    );
  }
}
