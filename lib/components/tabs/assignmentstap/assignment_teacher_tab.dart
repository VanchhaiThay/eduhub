import 'dart:io';
import 'package:eduhub/components/tabs/assignmentstap/assignmentPreviewpage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class QuestionData {
  TextEditingController questionController = TextEditingController();
  List<TextEditingController> optionControllers = [TextEditingController()];
  String? uploadedImageUrl;
  File? selectedImage;
  bool isUploading = false;
  String selectedType = 'Multiple Choice';

  void dispose() {
    questionController.dispose();
    for (var c in optionControllers) {
      c.dispose();
    }
  }
}

class AssignmentTeacherTab extends StatefulWidget {
  final String language;
  const AssignmentTeacherTab({super.key, required this.language});

  @override
  State<AssignmentTeacherTab> createState() => _AssignmentTeacherTabState();
}

class _AssignmentTeacherTabState extends State<AssignmentTeacherTab> {
  final _supabase = Supabase.instance.client;
  final String _bucketName = 'eduhub_assignments';
  final ImagePicker _picker = ImagePicker();

  final TextEditingController _titleController = TextEditingController();
  List<QuestionData> _questions = [];
  bool _isPublishing = false;

  @override
  void initState() {
    super.initState();
    _addNewQuestion();
  }

  @override
  void dispose() {
    _titleController.dispose();
    for (var q in _questions) {
      q.dispose();
    }
    super.dispose();
  }

  void _addNewQuestion() {
    setState(() => _questions.add(QuestionData()));
  }

  void _removeQuestion(int index) {
    if (_questions.length > 1) {
      setState(() {
        _questions[index].dispose();
        _questions.removeAt(index);
      });
    }
  }

  // --- NEW: PUBLISH FUNCTION ---
Future<void> _publishAssignment() async {
  if (_titleController.text.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Please enter an assignment title")),
    );
    return;
  }

  // 1. Prepare the data payload
  final assignmentData = {
    'title': _titleController.text,
    'language': widget.language,
    'questions': _questions.map((q) {
      return {
        'question_text': q.questionController.text,
        'type': q.selectedType,
        'image_url': q.uploadedImageUrl,
        'options': q.optionControllers.map((c) => c.text).toList(),
      };
    }).toList(),
  };

  // 2. Navigate to the Preview/View screen
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => AssignmentPreviewPage(data: assignmentData),
    ),
  );
}

  Future<void> _pickAndUploadImage(int questionIndex) async {
    final question = _questions[questionIndex];
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
      if (image == null) return;
      setState(() {
        question.selectedImage = File(image.path);
        question.isUploading = true;
      });
      final String fileName = 'q_${DateTime.now().millisecondsSinceEpoch}.jpg';
      await _supabase.storage.from(_bucketName).upload(fileName, File(image.path));
      final String publicUrl = _supabase.storage.from(_bucketName).getPublicUrl(fileName);
      setState(() {
        question.uploadedImageUrl = publicUrl;
        question.isUploading = false;
      });
    } catch (e) {
      setState(() => question.isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF0EBF8),
      // --- BOTTOM NAVIGATION BAR FOR ACTION BUTTONS ---
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _addNewQuestion,
                icon: const Icon(Icons.add),
                label: const Text("Add Question"),
                style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _isPublishing ? null : _publishAssignment,
                icon: _isPublishing 
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Icon(Icons.publish),
                label: Text(_isPublishing ? "Publishing..." : "Publish"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF38A39D),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 770),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Column(
              children: [
                _buildHeaderCard(isDark),
                const SizedBox(height: 12),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _questions.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) => _buildQuestionCard(index, isDark),
                ),
                const SizedBox(height: 40), // Space for bottom bar
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('New Assignment', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
          const SizedBox(height: 16),
          TextField(
            controller: _titleController,
            decoration: InputDecoration(
              filled: true,
              fillColor: isDark ? const Color(0xFF2C2C2C) : const Color(0xFFF1F3F4),
              hintText: 'Assignment Title (e.g. Midterm Quiz)',
              border: const UnderlineInputBorder(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(int qIndex, bool isDark) {
    final question = _questions[qIndex];
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: question.questionController,
                    decoration: const InputDecoration(filled: true, fillColor: Color(0xFFF1F3F4), hintText: "Question text", border: UnderlineInputBorder()),
                  ),
                ),
                IconButton(
                  icon: Icon(question.uploadedImageUrl == null ? Icons.image_outlined : Icons.check_circle, color: question.uploadedImageUrl == null ? Colors.grey : Colors.green),
                  onPressed: () => _pickAndUploadImage(qIndex),
                ),
                _buildDropdown(qIndex),
                if (_questions.length > 1)
                  IconButton(icon: const Icon(Icons.delete_outline, color: Colors.redAccent), onPressed: () => _removeQuestion(qIndex)),
              ],
            ),
            if (question.selectedImage != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Image.file(question.selectedImage!, height: 150, fit: BoxFit.contain),
              ),
            ...question.optionControllers.asMap().entries.map((entry) => _buildOptionRow(qIndex, entry.key)),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () => setState(() => question.optionControllers.add(TextEditingController())),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add option'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionRow(int qIndex, int oIndex) {
    final question = _questions[qIndex];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          const Icon(Icons.radio_button_unchecked, color: Colors.grey, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: question.optionControllers[oIndex],
              decoration: InputDecoration(hintText: "Option ${oIndex + 1}"),
            ),
          ),
          if (question.optionControllers.length > 1)
            IconButton(icon: const Icon(Icons.close, size: 18), onPressed: () => setState(() => question.optionControllers.removeAt(oIndex))),
        ],
      ),
    );
  }

  Widget _buildDropdown(int qIndex) {
    return DropdownButton<String>(
      value: _questions[qIndex].selectedType,
      items: const [
        DropdownMenuItem(value: 'Multiple Choice', child: Text('MCQ')),
        DropdownMenuItem(value: 'Short Answer', child: Text('Short')),
      ],
      onChanged: (val) => setState(() => _questions[qIndex].selectedType = val!),
    );
  }
}