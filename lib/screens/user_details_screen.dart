import 'package:flutter/material.dart';
import 'package:quiz_app_ar/models/user_model.dart';
import 'package:quiz_app_ar/services/auth_service.dart';

class UserDetailsScreen extends StatefulWidget {
  final User user;

  const UserDetailsScreen({super.key, required this.user});

  @override
  State<UserDetailsScreen> createState() => _UserDetailsScreenState();
}

class _UserDetailsScreenState extends State<UserDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _ageController;
  late TextEditingController _usernameController;
  late TextEditingController _passwordController;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _ageController = TextEditingController(text: widget.user.age.toString());
    _usernameController = TextEditingController(text: widget.user.username);
    _passwordController = TextEditingController(text: widget.user.password);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      final updatedUser = User(
        id: widget.user.id,
        name: _nameController.text.trim(),
        age: int.parse(_ageController.text.trim()),
        username: _usernameController.text.trim(),
        password: _passwordController.text.trim(),
        role: widget.user.role,
        isSuperAdmin: widget.user.isSuperAdmin,
        isApproved: widget.user.isApproved,
      );

      await AuthService.updateUser(updatedUser);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم حفظ التغييرات بنجاح')),
      );
      Navigator.pop(context, true); // إرجاع true للإشارة أن التحديث تم
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ: $e')),
      );
    } finally{
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تعديل بيانات المستخدم'),
        backgroundColor: Colors.indigo,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _loading ? null : _saveChanges,
            tooltip: 'حفظ التغييرات',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: widget.user.isAdmin ? Colors.purple : Colors.indigo,
                child: Text(
                  widget.user.name[0].toUpperCase(),
                  style: const TextStyle(fontSize: 40, color: Colors.white),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                widget.user.isAdmin ? 'أدمن' : 'مستخدم عادي',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  color: widget.user.isAdmin ? Colors.purple : Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 32),
              TextFormField(
                controller: _nameController,
                textAlign: TextAlign.right,
                decoration: const InputDecoration(
                  labelText: 'الاسم',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v == null || v.trim().isEmpty ? 'الرجاء إدخال الاسم' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _ageController,
                textAlign: TextAlign.right,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'العمر',
                  prefixIcon: Icon(Icons.cake),
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'الرجاء إدخال العمر';
                  final age = int.tryParse(v.trim());
                  if (age == null || age < 1 || age > 120) return 'عمر غير صحيح';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _usernameController,
                textAlign: TextAlign.right,
                decoration: const InputDecoration(
                  labelText: 'اسم المستخدم',
                  prefixIcon: Icon(Icons.account_circle),
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v == null || v.trim().isEmpty ? 'الرجاء إدخال اسم المستخدم' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                textAlign: TextAlign.right,
                decoration: const InputDecoration(
                  labelText: 'كلمة السر',
                  prefixIcon: Icon(Icons.lock),
                  border: OutlineInputBorder(),
                  helperText: 'يمكن للأدمن رؤية وتعديل كلمة السر',
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'الرجاء إدخال كلمة السر';
                  if (v.trim().length < 4) return 'كلمة السر يجب أن تكون 4 أحرف على الأقل';
                  return null;
                },
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: _loading ? null : _saveChanges,
                icon: _loading 
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.save),
                label: const Text('حفظ التغييرات', style: TextStyle(fontSize: 18)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
