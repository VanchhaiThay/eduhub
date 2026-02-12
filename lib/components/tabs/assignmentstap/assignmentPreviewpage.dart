import 'package:flutter/material.dart';

class AssignmentPreviewPage extends StatelessWidget {
  final Map<String, dynamic> data;

  const AssignmentPreviewPage({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final List questions = data['questions'];
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(data['title']),
        backgroundColor: const Color(0xFF38A39D),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: questions.length,
        itemBuilder: (context, index) {
          final q = questions[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Question ${index + 1}",
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    q['question_text'],
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                  
                  // Show Image if it exists
                  if (q['image_url'] != null) ...[
                    const SizedBox(height: 12),
                    Image.network(q['image_url'], height: 200, fit: BoxFit.contain),
                  ],

                  const SizedBox(height: 16),
                  
                  // Show Options or Short Answer field
                  if (q['type'] == 'Multiple Choice')
                    ...List.generate(q['options'].length, (i) {
                      return ListTile(
                        leading: const Icon(Icons.radio_button_off),
                        title: Text(q['options'][i]),
                        dense: true,
                      );
                    })
                  else
                    const TextField(
                      decoration: InputDecoration(
                        hintText: "Short answer text",
                        border: OutlineInputBorder(),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}