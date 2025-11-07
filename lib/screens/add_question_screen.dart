import 'package:flutter/material.dart';
import 'package:quiz_app_ar/models/user_model.dart';
import 'package:quiz_app_ar/question_model.dart';
import 'package:quiz_app_ar/services/questions_service.dart';

class AddQuestionScreen extends StatefulWidget {
  final User admin;

  const AddQuestionScreen({super.key, required this.admin});

  @override
  State<AddQuestionScreen> createState() => _AddQuestionScreenState();
}

class _AddQuestionScreenState extends State<AddQuestionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _questionController = TextEditingController();
  final List<TextEditingController> _optionControllers = List.generate(4, (_) => TextEditingController());
  final List<TextEditingController> _imageControllers = List.generate(4, (_) => TextEditingController());
  
  int _correctAnswerIndex = 0;
  DateTime? _targetDate;
  int? _minAge;
  int? _maxAge;
  bool _loading = false;

  @override
  void dispose() {
    _questionController.dispose();
    for (var controller in _optionControllers) {
      controller.dispose();
    }
    for (var controller in _imageControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: Colors.green),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _targetDate = picked);
    }
  }

  Future<void> _saveQuestion() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      final question = Question(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        question: _questionController.text.trim(),
        options: _optionControllers.map((c) => c.text.trim()).toList(),
        optionImages: _imageControllers.map((c) => c.text.trim().isEmpty ? null : c.text.trim()).toList(),
        answerIndex: _correctAnswerIndex,
        targetDate: _targetDate,
        minAge: _minAge,
        maxAge: _maxAge,
      );

      await QuestionsService.addQuestion(question);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم إضافة السؤال بنجاح ✓')),
      );
      Navigator.pop(context);
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
      appBar: AppBar(
        title: const Text('إضافة سؤال جديد'),
        backgroundColor: Colors.green,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // السؤال
            TextFormField(
              controller: _questionController,
              textAlign: TextAlign.right,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'نص السؤال',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              validator: (v) => v == null || v.trim().isEmpty ? 'الرجاء إدخال السؤال' : null,
            ),
            const SizedBox(height: 24),

            // الخيارات
            const Text('الخيارات:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ...List.generate(4, (index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Radio<int>(
                          value: index,
                          groupValue: _correctAnswerIndex,
                          onChanged: (v) => setState(() => _correctAnswerIndex = v!),
                        ),
                        Expanded(
                          child: TextFormField(
                            controller: _optionControllers[index],
                            textAlign: TextAlign.right,
                            decoration: InputDecoration(
                              labelText: 'الخيار ${index + 1}',
                              border: const OutlineInputBorder(),
                              suffixIcon: _correctAnswerIndex == index
                                  ? const Icon(Icons.check_circle, color: Colors.green)
                                  : null,
                            ),
                            validator: (v) => v == null || v.trim().isEmpty ? 'مطلوب' : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _imageControllers[index],
                      textAlign: TextAlign.right,
                      decoration: InputDecoration(
                        labelText: 'رابط الصورة (اختياري)',
                        border: const OutlineInputBorder(),
                        hintText: 'https://...',
                        hintStyle: TextStyle(color: Colors.grey[400]),
                      ),
                    ),
                  ],
                ),
              );
            }),

            const Divider(height: 32),

            // التاريخ
            ListTile(
              title: Text(
                _targetDate == null
                    ? 'تاريخ السؤال (اختياري)'
                    : 'التاريخ: ${_targetDate!.year}-${_targetDate!.month}-${_targetDate!.day}',
                textAlign: TextAlign.right,
              ),
              leading: const Icon(Icons.calendar_today),
              trailing: _targetDate != null
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => setState(() => _targetDate = null),
                    )
                  : null,
              onTap: _selectDate,
              tileColor: Colors.grey[100],
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            const SizedBox(height: 16),

            // الفئة العمرية
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    textAlign: TextAlign.right,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'الحد الأدنى للعمر',
                      border: OutlineInputBorder(),
                      hintText: 'اختياري',
                    ),
                    onChanged: (v) => _minAge = int.tryParse(v),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    textAlign: TextAlign.right,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'الحد الأقصى للعمر',
                      border: OutlineInputBorder(),
                      hintText: 'اختياري',
                    ),
                    onChanged: (v) => _maxAge = int.tryParse(v),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // زر الحفظ
            SizedBox(
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _loading ? null : _saveQuestion,
                icon: _loading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.save),
                label: const Text('حفظ السؤال', style: TextStyle(fontSize: 18)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
