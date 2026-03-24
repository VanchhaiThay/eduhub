import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Firebase Import

class AssignmentPreviewPage extends StatefulWidget {
  final Map<String, dynamic> data;
  final bool isTeacherPreview;

  const AssignmentPreviewPage({
    super.key,
    required this.data,
    this.isTeacherPreview = false,
  });

  @override
  State<AssignmentPreviewPage> createState() => _AssignmentPreviewPageState();
}

class _AssignmentPreviewPageState extends State<AssignmentPreviewPage> {
  final Map<int, String> _userAnswers = {};
  final Map<int, TextEditingController> _controllers = {};
  bool _showResults = false;
  bool _isPublishing = false;

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  // --- NEW FIREBASE PUBLISH LOGIC ---
  Future<void> _publishAssignment() async {
    setState(() => _isPublishing = true);

    try {
      final collection = FirebaseFirestore.instance.collection('assignments');
      final docRef = await collection.add({
        ...widget.data,
        'createdAt': FieldValue.serverTimestamp(),
      });

      final String assignmentId = docRef.id;
      final String shareableLink =
          "https://eduhub.app/assignment/$assignmentId";

      if (mounted) {
        _showLinkDialog(shareableLink);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Firebase Error: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isPublishing = false);
    }
  }

  void _showLinkDialog(String link) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 10),
            Text("Published!"),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Your assignment is live. Copy the link below to share with students:",
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade400),
              ),
              child: SelectableText(
                link,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: link));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Link copied to clipboard!")),
              );
            },
            child: const Text("COPY LINK"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close Dialog
              Navigator.pop(context); // Go back to Creation screen
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF38A39D),
            ),
            child: const Text("DONE", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // --- PREVIEW UI HELPERS ---

  void _handleSubmition(int totalQuestions) {
    bool allAnswered = true;
    for (int i = 0; i < totalQuestions; i++) {
      if (!_userAnswers.containsKey(i) || _userAnswers[i]!.trim().isEmpty) {
        allAnswered = false;
        break;
      }
    }

    if (!allAnswered) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please answer all questions"),
          backgroundColor: Colors.orange,
        ),
      );
    } else {
      setState(() => _showResults = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final List questions = widget.data['questions'] ?? [];
    final String title = widget.data['title'] ?? 'Untitled Assignment';
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF121212)
          : const Color(0xFFF0EBF8),
      appBar: AppBar(
        title: Text(widget.isTeacherPreview ? "Teacher Preview" : "Assignment"),
        backgroundColor: const Color(0xFF38A39D),
        elevation: 0,
        actions: [
          if (widget.isTeacherPreview)
            Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: Center(
                child: _isPublishing
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : ElevatedButton.icon(
                        onPressed: _publishAssignment,
                        icon: const Icon(Icons.send, size: 18),
                        label: const Text("PUBLISH"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF38A39D),
                        ),
                      ),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 770),
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildTitleHeader(title, isDark),
                const SizedBox(height: 16),
                if (_showResults && !widget.isTeacherPreview)
                  _buildSuccessBanner(),
                ...questions.asMap().entries.map((entry) {
                  return _buildInteractiveCard(entry.value, entry.key, isDark);
                }),
                const SizedBox(height: 24),

                if (!_showResults)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _handleSubmition(questions.length),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF38A39D),
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        "TEST SUBMISSION",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Use the same _buildSuccessBanner, _buildInteractiveCard, and _buildTitleHeader from your previous version
  Widget _buildSuccessBanner() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green),
      ),
      child: const Row(
        children: [
          Icon(Icons.check_circle, color: Colors.green),
          SizedBox(width: 12),
          Text(
            "Submission Successful!",
            style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildInteractiveCard(Map q, int index, bool isDark) {
    String type = q['type'] ?? 'Multiple Choice';
    int points = q['points'] ?? 1;
    bool isCorrect =
        _userAnswers[index]?.trim().toLowerCase() ==
        q['correct_answer']?.toString().toLowerCase();

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: (_showResults && widget.isTeacherPreview)
            ? Border.all(color: isCorrect ? Colors.green : Colors.red, width: 2)
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  q['question_text'] ?? '',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blueGrey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  "$points pts",
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          if (q['image_url'] != null && q['image_url'].isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Image.network(
                q['image_url'],
                height: 250,
                fit: BoxFit.contain,
              ),
            ),
          const SizedBox(height: 16),
          if (type == 'Multiple Choice')
            ...List.generate(
              q['options'].length,
              (i) => RadioListTile<String>(
                title: Text(q['options'][i]),
                value: q['options'][i],
                // ignore: deprecated_member_use
                groupValue: _userAnswers[index],
                activeColor: const Color(0xFF38A39D),
                // ignore: deprecated_member_use
                onChanged: _showResults
                    ? null
                    : (v) => setState(() => _userAnswers[index] = v!),
              ),
            )
          else
            TextField(
              controller: _controllers.putIfAbsent(
                index,
                () => TextEditingController(),
              ),
              enabled: !_showResults,
              onChanged: (v) => _userAnswers[index] = v,
              decoration: const InputDecoration(
                hintText: "Your answer",
                border: OutlineInputBorder(),
              ),
            ),

          if (_showResults && widget.isTeacherPreview)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                isCorrect
                    ? "Correct!"
                    : "Incorrect. Key: ${q['correct_answer']}",
                style: TextStyle(
                  color: isCorrect ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTitleHeader(String title, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: const Border(
          top: BorderSide(color: Color(0xFF38A39D), width: 10),
        ),
      ),
      child: Text(
        title,
        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
      ),
    );
  }
}
