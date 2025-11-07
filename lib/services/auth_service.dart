import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:quiz_app_ar/models/user_model.dart';
import 'package:http/http.dart' as http;
import 'package:quiz_app_ar/config/api_config.dart';

class AuthService {
  static const String _currentUserKey = 'current_user';
  static const String _adminSecretCode = 'ADMIN2025'; // كود سري للأدمن
  static const String _adminMasterPassword = 'CH@2025'; // كلمة سر الأدمن الرئيسي

  // التأكد من وجود حساب الأدمن الرئيسي (USER: ADMIN)
  static Future<void> ensurePrimaryAdminSeeded() async {
    var users = await getAllUsers();
    
    // احذف أي حساب موجود باسم ADMIN (قديم أو معلق)
    users.removeWhere((u) => u.username.toUpperCase() == 'ADMIN');
    
    // أنشئ حساب الأدمن الرئيسي من جديد
    final adminUser = User(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: 'أدمن رئيسي',
      age: 30,
      username: 'ADMIN',
      password: _adminMasterPassword, // كلمة سر الأدمن
      role: 'admin',
      isSuperAdmin: true,
      isApproved: true,
    );
    users.add(adminUser);
    await _saveAllUsers(users);
  }

  // إعادة تهيئة المستخدمين ليبقى فقط الأدمن الرئيسي
  static Future<void> resetToOnlyPrimaryAdmin() async {
    final prefs = await SharedPreferences.getInstance();
    final adminUser = User(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: 'أدمن رئيسي',
      age: 30,
      username: 'ADMIN',
      password: _adminMasterPassword,
      role: 'admin',
      isSuperAdmin: true,
      isApproved: true,
    );
    final users = <User>[adminUser];
    await _saveAllUsers(users);
    await prefs.remove(_currentUserKey); // تسجيل خروج أي مستخدم حالي
  }

  // تسجيل مستخدم جديد
  static Future<void> registerUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    
    // حفظ المستخدم الحالي
    await prefs.setString(_currentUserKey, json.encode(user.toJson()));
    
    // إضافة المستخدم لقائمة جميع المستخدمين
    final allUsers = await getAllUsers();
    allUsers.add(user);
    await _saveAllUsers(allUsers);
  }

  // تسجيل الدخول بواسطة اسم المستخدم
  static Future<User?> loginByUsername(String username) async {
    final users = await getAllUsers();
    try {
      final user = users.firstWhere(
        (u) => u.username.toLowerCase() == username.toLowerCase(),
      );
      
      // حفظ المستخدم الحالي
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_currentUserKey, json.encode(user.toJson()));
      
      return user;
    } catch (e) {
      return null;
    }
  }

  // التحقق من كلمة سر الأدمن
  static bool verifyAdminPassword(String password, User user) {
    if (!user.isAdmin) {
      // المستخدم العادي: تحقق من كلمة سره الخاصة
      return password == user.password;
    }
    // الأدمن: تحقق من كلمة سر الأدمن الرئيسية
    return password == _adminMasterPassword;
  }

  // ترقية المستخدم الحالي إلى أدمن باستخدام كود سري
  static Future<bool> activateAdminWithCode(String code, String userId) async {
    if (code != _adminSecretCode) return false;

    final users = await getAllUsers();
    final index = users.indexWhere((u) => u.id == userId);
    
    if (index == -1) return false;

    // تحقق إذا كان هناك أدمن رئيسي موجود
    final hasSuperAdmin = users.any((u) => u.isSuperAdmin);

    final updated = User(
      id: users[index].id,
      name: users[index].name,
      age: users[index].age,
      username: users[index].username,
      password: users[index].password,
      role: 'admin',
      isSuperAdmin: !hasSuperAdmin, // أول أدمن يصير رئيسي
      isApproved: true, // الأدمن مباشرة موافق عليه
    );

    users[index] = updated;
    await _saveAllUsers(users);
    await _saveCurrentUser(updated);

    return true;
  }

  // الحصول على المستخدم الحالي
  static Future<User?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_currentUserKey);
    if (userJson == null) return null;
    return User.fromJson(json.decode(userJson));
  }

  // تسجيل الخروج
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_currentUserKey);
  }


  // الحصول على جميع المستخدمين (أونلاين)
  static Future<List<User>> getAllUsers() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/b/${ApiConfig.usersBinId}/latest'),
        headers: {
          'X-Master-Key': ApiConfig.jsonBinApiKey,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> usersList = data['record'] ?? [];
        return usersList.map((u) => User.fromJson(u)).toList();
      }
    } catch (e) {
      print('Error fetching users: $e');
    }
    return [];
  }

  // حفظ جميع المستخدمين (أونلاين)
  static Future<void> _saveAllUsers(List<User> users) async {
    try {
      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/b/${ApiConfig.usersBinId}'),
        headers: {
          'Content-Type': 'application/json',
          'X-Master-Key': ApiConfig.jsonBinApiKey,
        },
        body: json.encode(users.map((u) => u.toJson()).toList()),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to save users: ${response.statusCode}');
      }
    } catch (e) {
      print('Error saving users: $e');
      rethrow;
    }
  }

  // ترقية مستخدم إلى أدمن (للأدمن الرئيسي فقط)
  static Future<void> promoteToAdmin(String userId) async {
    final users = await getAllUsers();
    final index = users.indexWhere((u) => u.id == userId);
    if (index != -1) {
      final updated = User(
        id: users[index].id,
        name: users[index].name,
        age: users[index].age,
        username: users[index].username,
        password: users[index].password,
        role: 'admin',
        isSuperAdmin: false,
        isApproved: true, // الأدمن مباشرة موافق عليه
      );
      users[index] = updated;
      await _saveAllUsers(users);

      // تحديث المستخدم الحالي إن كان هو نفسه
      final current = await getCurrentUser();
      if (current != null && current.id == userId) {
        await _saveCurrentUser(updated);
      }
    }
  }

  // ترقية مستخدم إلى أدمن رئيسي (مرة واحدة يدوياً)
  static Future<void> makeSuperAdmin(String userId) async {
    final users = await getAllUsers();
    final index = users.indexWhere((u) => u.id == userId);
    if (index != -1) {
      final updated = User(
        id: users[index].id,
        name: users[index].name,
        age: users[index].age,
        username: users[index].username,
        password: users[index].password,
        role: 'admin',
        isSuperAdmin: true,
        isApproved: true, // الأدمن مباشرة موافق عليه
      );
      users[index] = updated;
      await _saveAllUsers(users);

      final current = await getCurrentUser();
      if (current != null && current.id == userId) {
        await _saveCurrentUser(updated);
      }
    }
  }

  static Future<void> _saveCurrentUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currentUserKey, json.encode(user.toJson()));
  }

  // التحقق إذا كان هناك مستخدم مسجل دخول
  static Future<bool> isLoggedIn() async {
    final user = await getCurrentUser();
    return user != null;
  }

  // الحصول على المستخدمين المعلقين (بانتظار الموافقة)
  static Future<List<User>> getPendingUsers() async {
    final users = await getAllUsers();
    return users.where((u) => !u.isApproved && !u.isAdmin).toList();
  }

  // الموافقة على مستخدم
  static Future<void> approveUser(String userId) async {
    final users = await getAllUsers();
    final index = users.indexWhere((u) => u.id == userId);
    if (index != -1) {
      final updated = User(
        id: users[index].id,
        name: users[index].name,
        age: users[index].age,
        username: users[index].username,
        password: users[index].password,
        role: users[index].role,
        isSuperAdmin: users[index].isSuperAdmin,
        isApproved: true,
      );
      users[index] = updated;
      await _saveAllUsers(users);
    }
  }

  // رفض مستخدم (حذفه)
  static Future<void> rejectUser(String userId) async {
    final users = await getAllUsers();
    users.removeWhere((u) => u.id == userId);
    await _saveAllUsers(users);
  }

  // تحديث بيانات مستخدم (للأدمن)
  static Future<void> updateUser(User updatedUser) async {
    final users = await getAllUsers();
    final index = users.indexWhere((u) => u.id == updatedUser.id);
    if (index != -1) {
      users[index] = updatedUser;
      await _saveAllUsers(users);

      // تحديث المستخدم الحالي إن كان هو نفسه
      final current = await getCurrentUser();
      if (current != null && current.id == updatedUser.id) {
        await _saveCurrentUser(updatedUser);
      }
    }
  }

  // حذف مستخدم/أدمن (للأدمن الرئيسي فقط)
  static Future<void> deleteUser(String userId) async {
    final users = await getAllUsers();
    users.removeWhere((u) => u.id == userId);
    await _saveAllUsers(users);
  }
}
