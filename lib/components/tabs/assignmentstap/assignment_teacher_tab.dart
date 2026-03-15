import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Added Firebase
import 'package:eduhub/components/tabs/assignmentstap/assignmentPreviewpage.dart';

class QuestionData {
  TextEditingController questionController = TextEditingController();
  TextEditingController pointsController = TextEditingController(text: "1");
  List<TextEditingController> optionControllers = [TextEditingController()];
  String? uploadedImageUrl;
  File? selectedImage;
  bool isUploading = false;
  String selectedType = 'Multiple Choice';
  String? correctAnswer;

  void dispose() {
    questionController.dispose();
    pointsController.dispose();
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
  final _firestore = FirebaseFirestore.instance; // Firebase Instance
  final String _bucketName = 'eduhub_assignments';
  final ImagePicker _picker = ImagePicker();

  final TextEditingController _titleController = TextEditingController();
  List<QuestionData> _questions = [];
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _questions.add(QuestionData());
  }

  @override
  void dispose() {
    _titleController.dispose();
    for (var q in _questions) {
      q.dispose();
    }
    super.dispose();
  }

  // --- IMAGE METHODS (Using Supabase) ---

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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Upload failed: $e")));
    }
  }

  void _deleteImage(int questionIndex) {
    setState(() {
      _questions[questionIndex].selectedImage = null;
      _questions[questionIndex].uploadedImageUrl = null;
    });
  }

  // --- FIREBASE STORAGE LOGIC ---

  Future<void> _saveToFirebaseAndPreview() async {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please enter a title")));
      return;
    }

    setState(() => _isSaving = true);

    try {
      final assignmentData = {
        'title': _titleController.text,
        'language': widget.language,
        'createdAt': FieldValue.serverTimestamp(),
        'questions': _questions.map((q) {
          return {
            'question_text': q.questionController.text,
            'type': q.selectedType,
            'image_url': q.uploadedImageUrl ?? "",
            'options': q.optionControllers.map((c) => c.text).toList(),
            'correct_answer': q.correctAnswer ?? "",
            'points': int.tryParse(q.pointsController.text) ?? 1,
          };
        }).toList(),
      };

      // Store in Firestore
      DocumentReference docRef = await _firestore.collection('assignments').add(assignmentData);

      setState(() => _isSaving = false);

      // Navigate to Preview
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AssignmentPreviewPage(
              data: {...assignmentData, 'id': docRef.id}, // Pass ID if needed
              isTeacherPreview: true,
            ),
          ),
        );
      }
    } catch (e) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Firebase Error: $e")));
    }
  }

  void _handleNewAssignment() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Start New?"),
        content: const Text("Clear all current questions?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              setState(() {
                for (var q in _questions) q.dispose();
                _questions = [QuestionData()];
                _titleController.clear();
              });
              Navigator.pop(context);
            },
            child: const Text("Clear", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // --- BUILD METHODS ---

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF0EBF8),
      bottomNavigationBar: _buildBottomBar(isDark),
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
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar(bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
      ),
      child: Row(
        children: [
          _buildCompactButton(onPressed: _handleNewAssignment, icon: Icons.refresh, label: "New", color: Colors.blueGrey, isOutlined: true),
          const SizedBox(width: 8),
          _buildCompactButton(onPressed: () => setState(() => _questions.add(QuestionData())), icon: Icons.add, label: "Add", color: Colors.blueAccent, isOutlined: true),
          const SizedBox(width: 8),
          _buildCompactButton(
            onPressed: _isSaving ? null : _saveToFirebaseAndPreview, 
            icon: _isSaving ? Icons.hourglass_top : Icons.remove_red_eye, 
            label: _isSaving ? "Saving..." : "Preview", 
            color: const Color(0xFF38A39D), 
            isOutlined: false
          ),
        ],
      ),
    );
  }

  Widget _buildCompactButton({required VoidCallback? onPressed, required IconData icon, required String label, required Color color, required bool isOutlined}) {
    return Expanded(
      child: isOutlined
          ? OutlinedButton.icon(
              onPressed: onPressed,
              icon: Icon(icon, size: 18),
              label: Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              style: OutlinedButton.styleFrom(
                foregroundColor: color,
                side: BorderSide(color: color.withOpacity(0.5)),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            )
          : ElevatedButton.icon(
              onPressed: onPressed,
              icon: Icon(icon, size: 18),
              label: Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
    );
  }

  Widget _buildHeaderCard(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(color: isDark ? const Color(0xFF1E1E1E) : Colors.white, borderRadius: BorderRadius.circular(8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Assignment Editor', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
          const SizedBox(height: 16),
          TextField(
            controller: _titleController,
            decoration: InputDecoration(
              filled: true,
              fillColor: isDark ? const Color(0xFF2C2C2C) : const Color(0xFFF1F3F4),
              hintText: 'Enter Assignment Title...',
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
      decoration: BoxDecoration(color: isDark ? const Color(0xFF1E1E1E) : Colors.white, borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextField(
                    controller: question.questionController,
                    decoration: const InputDecoration(filled: true, fillColor: Color(0xFFF1F3F4), hintText: "Question", border: UnderlineInputBorder()),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(question.uploadedImageUrl == null ? Icons.image_outlined : Icons.check_circle, color: question.uploadedImageUrl == null ? Colors.grey : Colors.green),
                  onPressed: () => _pickAndUploadImage(qIndex),
                ),
                _buildDropdown(qIndex),
                if (_questions.length > 1)
                  IconButton(icon: const Icon(Icons.delete_outline, color: Colors.redAccent), onPressed: () => setState(() {
                    question.dispose();
                    _questions.removeAt(qIndex);
                  })),
              ],
            ),
            
            if (question.isUploading)
              const Center(child: Padding(padding: EdgeInsets.all(8.0), child: CircularProgressIndicator()))
            else if (question.selectedImage != null)
              Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(question.selectedImage!, height: 150, width: double.infinity, fit: BoxFit.contain),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    right: 0,
                    child: CircleAvatar(
                      backgroundColor: Colors.red,
                      radius: 18,
                      child: IconButton(
                        icon: const Icon(Icons.close, color: Colors.white, size: 18),
                        onPressed: () => _deleteImage(qIndex),
                      ),
                    ),
                  ),
                ],
              ),
            
            const Divider(),
            Row(
              children: [
                SizedBox(
                  width: 60,
                  child: TextField(
                    controller: question.pointsController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(labelText: "Pts", border: OutlineInputBorder()),
                  ),
                ),
                const SizedBox(width: 12),
                const Text("Set Correct Answer", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
              ],
            ),
            const SizedBox(height: 8),
            if (question.selectedType == 'Multiple Choice') ...[
              ...question.optionControllers.asMap().entries.map((entry) => _buildOptionRow(qIndex, entry.key)),
              TextButton.icon(
                onPressed: () => setState(() => question.optionControllers.add(TextEditingController())),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add option'),
              ),
            ] else ...[
              TextField(
                onChanged: (val) => question.correctAnswer = val,
                decoration: const InputDecoration(hintText: "Type correct answer...", prefixIcon: Icon(Icons.verified, color: Colors.green), border: OutlineInputBorder()),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildOptionRow(int qIndex, int oIndex) {
    final question = _questions[qIndex];
    bool isSelected = question.correctAnswer == question.optionControllers[oIndex].text && question.optionControllers[oIndex].text.isNotEmpty;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          IconButton(
            icon: Icon(isSelected ? Icons.check_circle : Icons.radio_button_unchecked, color: isSelected ? Colors.green : Colors.grey),
            onPressed: () => setState(() => question.correctAnswer = question.optionControllers[oIndex].text),
          ),
          Expanded(child: TextField(controller: question.optionControllers[oIndex], decoration: InputDecoration(hintText: "Option ${oIndex + 1}"))),
          if (question.optionControllers.length > 1) IconButton(icon: const Icon(Icons.close, size: 18), onPressed: () => setState(() => question.optionControllers.removeAt(oIndex))),
        ],
      ),
    );
  }

  Widget _buildDropdown(int qIndex) {
    return DropdownButton<String>(
      value: _questions[qIndex].selectedType,
      items: const [DropdownMenuItem(value: 'Multiple Choice', child: Text('MCQ')), DropdownMenuItem(value: 'Short Answer', child: Text('Short'))],
      onChanged: (val) => setState(() {
        _questions[qIndex].selectedType = val!;
        _questions[qIndex].correctAnswer = null;
      }),
    );
  }
}