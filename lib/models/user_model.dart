class User {
  final String id;
  final String name;
  final int age;
  final String username;
  final String password; // كلمة سر المستخدم
  final String role; // 'admin' or 'user'
  final bool isSuperAdmin; // للأدمن الرئيسي
  final bool isApproved; // هل تمت الموافقة على المستخدم من قبل الأدمن

  User({
    required this.id,
    required this.name,
    required this.age,
    required this.username,
    required this.password,
    this.role = 'user',
    this.isSuperAdmin = false,
    this.isApproved = false,
  });

  bool get isAdmin => role == 'admin';

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      age: json['age'] ?? 0,
      username: json['username'] ?? '',
      password: json['password'] ?? '',
      role: json['role'] ?? 'user',
      isSuperAdmin: json['isSuperAdmin'] ?? false,
      isApproved: json['isApproved'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'age': age,
      'username': username,
      'password': password,
      'role': role,
      'isSuperAdmin': isSuperAdmin,
      'isApproved': isApproved,
    };
  }
}
