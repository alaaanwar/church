import 'package:flutter/material.dart';
import 'package:quiz_app_ar/models/user_model.dart';
import 'package:quiz_app_ar/services/auth_service.dart';
import 'package:quiz_app_ar/home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      // التحقق إذا هذا أول مستخدم (بيصير أدمن رئيسي تلقائياً)
      final existingUsers = await AuthService.getAllUsers();
      final isFirstUser = existingUsers.isEmpty;

      final username = _usernameController.text.trim();
      final usernameExists = existingUsers.any((u) => u.username.toLowerCase() == username.toLowerCase());
      if (usernameExists) {
        if (mounted) {
          setState(() => _loading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('اسم المستخدم مستخدم بالفعل، الرجاء اختيار اسم آخر.')),
          );
        }
        return;
      }

      final user = User(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        age: int.parse(_ageController.text.trim()),
        username: username,
        password: _passwordController.text.trim(),
        role: isFirstUser ? 'admin' : 'user', // أول مستخدم يصير أدمن
        isSuperAdmin: isFirstUser, // أول مستخدم يصير Super Admin
        isApproved: isFirstUser, // أول مستخدم موافق عليه تلقائياً
      );

      await AuthService.registerUser(user);

      if (!mounted) return;
      
      if (isFirstUser) {
        // أول مستخدم يدخل مباشرة كأدمن رئيسي
        Navigator.pushReplacementNamed(context, '/login');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم تسجيلك كأدمن رئيسي. يمكنك تسجيل الدخول الآن'),
            duration: Duration(seconds: 3),
          ),
        );
      } else {
        // باقي المستخدمين ينتظرون الموافقة
        await AuthService.logout(); // تسجيل الخروج مباشرة
        
        if (!mounted) return;
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            title: const Text(
              'تم التسجيل بنجاح',
              textAlign: TextAlign.center,
            ),
            content: const Text(
              'حسابك بانتظار موافقة الأدمن. سيتم إعلامك عند الموافقة على حسابك.',
              textAlign: TextAlign.center,
            ),
            actions: [
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                  child: const Text('حسناً'),
                ),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ: $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.indigo.shade400, Colors.indigo.shade900],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.church, size: 80, color: Colors.indigo),
                        const SizedBox(height: 16),
                        const Text(
                          'التطبيق الروحي',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.indigo,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'إنشاء حساب جديد',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
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
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: 'كلمة السر',
                            prefixIcon: Icon(Icons.lock),
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return 'الرجاء إدخال كلمة السر';
                            if (v.trim().length < 4) return 'كلمة السر يجب أن تكون 4 أحرف على الأقل';
                            return null;
                          },
                        ),
                        const SizedBox(height: 32),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _loading ? null : _register,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.indigo,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: _loading
                                ? const CircularProgressIndicator(color: Colors.white)
                                : const Text('تسجيل', style: TextStyle(fontSize: 18)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
