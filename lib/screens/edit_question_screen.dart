import 'package:flutter/material.dart';
import 'package:quiz_app_ar/question_model.dart';
import 'package:quiz_app_ar/services/questions_service.dart';

class EditQuestionScreen extends StatefulWidget {
  final Question question;

  const EditQuestionScreen({super.key, required this.question});

  @override
  State<EditQuestionScreen> createState() => _EditQuestionScreenState();
}

class _EditQuestionScreenState extends State<EditQuestionScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _questionController;
  late List<TextEditingController> _optionControllers;
  late TextEditingController _minAgeController;
  late TextEditingController _maxAgeController;
  late DateTime? _selectedDate;
  late int _correctAnswerIndex;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _questionController = TextEditingController(text: widget.question.question);
    _optionControllers = widget.question.options
        .map((opt) => TextEditingController(text: opt))
        .toList();
    _minAgeController = TextEditingController(text: widget.question.minAge.toString());
    _maxAgeController = TextEditingController(text: widget.question.maxAge.toString());
  _selectedDate = widget.question.targetDate;
    _correctAnswerIndex = widget.question.answerIndex;
  }

  @override
  void dispose() {
    _questionController.dispose();
    for (var controller in _optionControllers) {
      controller.dispose();
    }
    _minAgeController.dispose();
    _maxAgeController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      final updatedQuestion = Question(
        id: widget.question.id,
        question: _questionController.text.trim(),
        options: _optionControllers.map((c) => c.text.trim()).toList(),
        answerIndex: _correctAnswerIndex,
        targetDate: _selectedDate,
        minAge: int.parse(_minAgeController.text.trim()),
        maxAge: int.parse(_maxAgeController.text.trim()),
      );

      await QuestionsService.updateQuestion(updatedQuestion);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم تحديث السؤال بنجاح')),
      );
      Navigator.pop(context, true);
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
        title: const Text('تعديل السؤال'),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _loading ? null : _saveChanges,
            tooltip: 'حفظ',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _questionController,
                textAlign: TextAlign.right,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'السؤال',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v == null || v.trim().isEmpty ? 'الرجاء إدخال السؤال' : null,
              ),
              const SizedBox(height: 16),
              const Text(
                'الخيارات:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                textAlign: TextAlign.right,
              ),
              const SizedBox(height: 8),
              ..._optionControllers.asMap().entries.map((entry) {
                final index = entry.key;
                final controller = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Radio<int>(
                        value: index,
                        groupValue: _correctAnswerIndex,
                        onChanged: (val) => setState(() => _correctAnswerIndex = val!),
                      ),
                      Expanded(
                        child: TextFormField(
                          controller: controller,
                          textAlign: TextAlign.right,
                          decoration: InputDecoration(
                            labelText: 'الخيار ${index + 1}',
                            border: const OutlineInputBorder(),
                          ),
                          validator: (v) => v == null || v.trim().isEmpty ? 'مطلوب' : null,
                        ),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _minAgeController,
                      textAlign: TextAlign.right,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'الحد الأدنى للعمر',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'مطلوب';
                        final age = int.tryParse(v.trim());
                        if (age == null || age < 0) return 'غير صحيح';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _maxAgeController,
                      textAlign: TextAlign.right,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'الحد الأعلى للعمر',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'مطلوب';
                        final age = int.tryParse(v.trim());
                        if (age == null || age < 0) return 'غير صحيح';
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ListTile(
                title: Text(
                  'التاريخ المستهدف: '
                  '${_selectedDate != null ? '${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}' : 'غير محدد'}',
                  textAlign: TextAlign.right,
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate ?? DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2030),
                  );
                  if (picked != null) {
                    setState(() {
                      _selectedDate = picked;
                    });
                  }
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _loading ? null : _saveChanges,
                icon: _loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.save),
                label: const Text('حفظ التعديلات', style: TextStyle(fontSize: 18)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
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
