Quiz App (عربي) - Flutter
=========================

<!-- Test commit to trigger GitHub Actions workflow -->
ملف المشروع هذا يحتوي على تطبيق كويز بسيط بالعربي يعتمد على تحميل الأسئلة من ملف JSON خارجي.

مكوّنات المشروع:
- pubspec.yaml
- lib/main.dart
- lib/quiz_screen.dart
- lib/question_model.dart
- lib/result_screen.dart
- assets/questions.json (نموذج محلي)
- README.md (هذا الملف)

كيفية الاستخدام (سريع):
1. قم بتثبيت Flutter واتباع دليل التثبيت الرسمي: https://docs.flutter.dev/get-started/install
2. افتح المشروع في VS Code أو Android Studio.
3. في ملف lib/quiz_screen.dart عليك تعديل المتغير `questionsUrl` ووضع رابط الـ JSON العام (raw) الخاص بك، مثلاً ملف في GitHub:
   - انشر ملف assets/questions.json على GitHub في repo خاص أو gist، ثم استخدم رابط raw (مثال):
     https://raw.githubusercontent.com/your-username/your-repo/main/questions.json
4. ثم شغّل:
   flutter pub get
   flutter run

ملاحظات إضافية:
- لتجربة محليًا بدون استضافة: يمكنك تعديل الكود لقراءة الملف assets/questions.json بدلًا من الإنترنت.
- لإضافة ميزات لاحقًا: تسجيل دخول، تخزين النتائج في Firebase، لوحة صدارة، أو تصميم واجهة أجمل.

تنبيه تقني:
- رابط JSON يجب أن يكون بصيغة صحيحة وبنفس بنية العناصر الموجودة في assets/questions.json
- إذا واجهت أي خطأ أثناء جلب الـ JSON، سيعرض التطبيق رسالة «لم يتم العثور على أسئلة» أو يظهر خطأ في الـ console.

---
README (English short)
- Edit lib/quiz_screen.dart -> questionsUrl to point to your raw JSON URL.
- Run: flutter pub get && flutter run
