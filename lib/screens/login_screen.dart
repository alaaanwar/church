import 'package:flutter/material.dart';
import 'package:quiz_app_ar/models/user_model.dart';
import 'package:quiz_app_ar/services/auth_service.dart';
import 'package:quiz_app_ar/home_screen.dart';
import 'package:quiz_app_ar/screens/register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      final username = _usernameController.text.trim();
      // تأكد من وجود الأدمن الرئيسي إذا لزم
      if (username.toUpperCase() == 'ADMIN') {
        await AuthService.ensurePrimaryAdminSeeded();
      }

      final user = await AuthService.loginByUsername(username);

      if (user == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('اسم المستخدم غير موجود')),
        );
        setState(() => _loading = false);
        return;
      }

      // إذا كان المستخدم أدمن، تحقق من كلمة السر المطلوبة
      if (user.isAdmin) {
        final password = _passwordController.text;
        final ok = AuthService.verifyAdminPassword(password, user);
        if (!ok) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('كلمة سر الأدمن غير صحيحة')),
          );
          setState(() => _loading = false);
          return;
        }
      } else {
        // المستخدم العادي: تحقق من كلمة سره
        final password = _passwordController.text;
        final ok = AuthService.verifyAdminPassword(password, user);
        if (!ok) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('كلمة السر غير صحيحة')),
          );
          setState(() => _loading = false);
          return;
        }
      }

      // التحقق من موافقة الأدمن (إلا إذا كان المستخدم أدمن)
      if (!user.isApproved && !user.isAdmin) {
        if (!mounted) return;
        await AuthService.logout(); // تسجيل الخروج
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('حسابك بانتظار موافقة الأدمن'),
            duration: Duration(seconds: 3),
          ),
        );
        setState(() => _loading = false);
        return;
      }

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomeScreen(user: user)),
      );
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
                          'تسجيل الدخول',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                        const SizedBox(height: 32),
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
                          ),
                          obscureText: true,
                          validator: (v) => v == null || v.trim().isEmpty ? 'الرجاء إدخال كلمة السر' : null,
                        ),
                        const SizedBox(height: 32),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _loading ? null : _login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.indigo,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: _loading
                                ? const CircularProgressIndicator(color: Colors.white)
                                : const Text('دخول', style: TextStyle(fontSize: 18)),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (_) => const RegisterScreen()),
                            );
                          },
                          child: const Text(
                            'ليس لديك حساب؟ سجل الآن',
                            style: TextStyle(fontSize: 16),
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
