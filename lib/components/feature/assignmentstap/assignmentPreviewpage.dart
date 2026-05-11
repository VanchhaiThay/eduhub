import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Firebase Import
import '../../../services/assignment_completion_service.dart';

class AssignmentPreviewPage extends StatefulWidget {
  final Map<String, dynamic> data;
  final bool isTeacherPreview;
  final Future<void> Function()? onSaveCallback;

  const AssignmentPreviewPage({
    super.key,
    required this.data,
    this.isTeacherPreview = false,
    this.onSaveCallback,
  });

  @override
  State<AssignmentPreviewPage> createState() => _AssignmentPreviewPageState();
}

class _AssignmentPreviewPageState extends State<AssignmentPreviewPage> {
  final Map<int, String> _userAnswers = {};
  final Map<int, TextEditingController> _controllers = {};
  bool _showResults = false;
  bool _isPublishing = false;
  bool _isPreviewMode = false;
  bool _isSaving = false;

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  // --- SAVE FUNCTIONALITY FOR TEACHER MODE ---
  Future<void> _saveAssignment() async {
    if (widget.onSaveCallback == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Save functionality not available"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      await widget.onSaveCallback!();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Assignment saved successfully!"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Save failed: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
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

  void _saveProgress() {
    // Save current answers to local storage or show a confirmation
    final savedAnswers =
        _userAnswers.entries.where((entry) => entry.value.isNotEmpty).toList();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text("Progress saved! ${savedAnswers.length} questions answered."),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _togglePreview() {
    // For teacher preview, always show answer validation dialog
    if (widget.isTeacherPreview) {
      _showTeacherAnswerValidation();
    } else {
      // For students, toggle preview mode as before
      setState(() {
        _isPreviewMode = !_isPreviewMode;
      });

      if (_isPreviewMode) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Preview mode: Correct answers are now visible"),
            backgroundColor: Colors.blue,
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Preview mode disabled"),
            backgroundColor: Colors.grey,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _handleSubmition(int totalQuestions) async {
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
      // Mark assignment as completed
      try {
        final assignmentId = widget.data['id'];
        if (assignmentId != null) {
          await AssignmentCompletionService.markAssignmentCompleted(
              assignmentId);
        }
      } catch (e) {
        print('Error marking assignment as completed: $e');
      }

      setState(() => _showResults = true);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Assignment submitted successfully!"),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  void _showTeacherAnswerValidation() {
    final List questions = widget.data['questions'] ?? [];
    final List<Map<String, dynamic>> answerResults = [];

    // Show all questions with their correct answers
    for (int i = 0; i < questions.length; i++) {
      final question = questions[i];
      final String? teacherAnswer = _userAnswers[i];
      final String? correctAnswer = question['correct_answer']?.toString();

      // Always include the question, even if no answer is selected
      final bool hasAnswer = teacherAnswer != null && teacherAnswer.isNotEmpty;
      final bool isCorrect = hasAnswer &&
          teacherAnswer.trim().toLowerCase() == correctAnswer?.toLowerCase();

      answerResults.add({
        'questionNumber': i + 1,
        'questionText': question['question_text'] ?? 'Question ${i + 1}',
        'teacherAnswer': hasAnswer ? teacherAnswer : 'No answer selected',
        'correctAnswer': correctAnswer ?? 'No correct answer set',
        'isCorrect': isCorrect,
        'hasAnswer': hasAnswer,
      });
    }

    _showAnswerValidationDialog(answerResults);
  }

  void _showAnswerValidationDialog(List<Map<String, dynamic>> results) {
    final int answeredCount = results.where((r) => r['hasAnswer']).length;
    final int correctCount = results.where((r) => r['isCorrect']).length;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Row(
          children: [
            Icon(
              correctCount == answeredCount && answeredCount > 0
                  ? Icons.check_circle
                  : Icons.info,
              color: correctCount == answeredCount && answeredCount > 0
                  ? Colors.green
                  : Colors.orange,
              size: 28,
            ),
            const SizedBox(width: 12),
            Text(
              "Answer Validation",
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                answeredCount > 0
                    ? "You selected $correctCount out of $answeredCount answers correctly!"
                    : "No answers selected. Showing all questions with correct answers.",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: answeredCount > 0 && correctCount == answeredCount
                      ? Colors.green
                      : Colors.orange,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "Answer Details:",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                constraints: const BoxConstraints(maxHeight: 300),
                child: SingleChildScrollView(
                  child: Column(
                    children: results
                        .map((result) => _buildAnswerResultItem(result))
                        .toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("CLOSE"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Show the regular preview message after closing dialog
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content:
                      Text("Preview mode: Correct answers are now visible"),
                  backgroundColor: Colors.blue,
                  duration: Duration(seconds: 2),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF38A39D),
            ),
            child: const Text(
              "CONTINUE",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnswerResultItem(Map<String, dynamic> result) {
    final bool isCorrect = result['isCorrect'];
    final bool hasAnswer = result['hasAnswer'];
    final int questionNumber = result['questionNumber'];
    final String teacherAnswer = result['teacherAnswer'];
    final String correctAnswer = result['correctAnswer'];

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: !hasAnswer
            ? Colors.grey.withOpacity(0.1)
            : isCorrect
                ? Colors.green.withOpacity(0.1)
                : Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: !hasAnswer
              ? Colors.grey.withOpacity(0.3)
              : isCorrect
                  ? Colors.green.withOpacity(0.3)
                  : Colors.red.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                !hasAnswer
                    ? Icons.info_outline
                    : isCorrect
                        ? Icons.check_circle
                        : Icons.cancel,
                color: !hasAnswer
                    ? Colors.grey
                    : isCorrect
                        ? Colors.green
                        : Colors.red,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                "Question $questionNumber",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: !hasAnswer
                      ? Colors.grey
                      : isCorrect
                          ? Colors.green
                          : Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            "Your answer: $teacherAnswer",
            style: TextStyle(
              fontSize: 14,
              fontStyle: hasAnswer ? FontStyle.normal : FontStyle.italic,
              color: hasAnswer ? null : Colors.grey,
            ),
          ),
          if (!hasAnswer) ...[
            Text(
              "Correct answer: $correctAnswer",
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.blue,
              ),
            ),
          ] else if (!isCorrect) ...[
            Text(
              "Correct answer: $correctAnswer",
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.green,
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List questions = widget.data['questions'] ?? [];
    final String title = widget.data['title'] ?? 'Untitled Assignment';
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    // Debug logging
    print('AssignmentPreviewPage - Data received: ${widget.data}');
    print('AssignmentPreviewPage - Questions: $questions');
    print('AssignmentPreviewPage - Questions length: ${questions.length}');

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF121212) : const Color(0xFFF0EBF8),
      appBar: AppBar(
        title: Text(widget.isTeacherPreview ? "Teacher Preview" : "Assignment"),
        backgroundColor: const Color(0xFF38A39D),
        elevation: 0,
        actions: [],
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
                if (widget.isTeacherPreview)
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isSaving ? null : _saveAssignment,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: _isSaving
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  "SAVE",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 16),
                                ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _togglePreview(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            "PREVIEW",
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  )
                else
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: SizedBox(
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
                          "SUBMIT",
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
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
    bool isCorrect = _userAnswers[index]?.trim().toLowerCase() ==
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
                height: MediaQuery.of(context).size.height * 0.6,
                width: double.infinity,
                fit: BoxFit.contain,
              ),
            ),
          const SizedBox(height: 16),
          if (type == 'Multiple Choice')
            ..._buildMultipleChoiceOptions(q, index)
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
          if (_isPreviewMode && !widget.isTeacherPreview)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.blue),
                ),
                child: Text(
                  "Correct Answer: ${q['correct_answer']}",
                  style: const TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  List<Widget> _buildMultipleChoiceOptions(Map q, int index) {
    final List<String> options = [];
    if (q['options'] != null) {
      if (q['options'] is List) {
        for (var option in q['options']) {
          if (option is String) {
            options.add(option);
          } else if (option is Map && option['option_text'] != null) {
            options.add(option['option_text'].toString());
          }
        }
      }
    }

    return List.generate(
      options.length,
      (i) => RadioListTile<String>(
        title: Text(options[i]),
        value: options[i],
        // ignore: deprecated_member_use
        groupValue: _userAnswers[index],
        activeColor: const Color(0xFF38A39D),
        // ignore: deprecated_member_use
        onChanged: _showResults
            ? null
            : (v) => setState(() => _userAnswers[index] = v!),
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
