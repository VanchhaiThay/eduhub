import 'package:flutter/material.dart';

class ClassDetailPage extends StatelessWidget {
  final String className;
  final String classId;

  const ClassDetailPage({
    super.key,
    required this.className,
    required this.classId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(className)),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
          ],
        ),
      ),
    );
  }
}
