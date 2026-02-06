import 'package:flutter/material.dart';

class Grade1Page extends StatefulWidget {
  const Grade1Page({super.key});

  @override
  State<Grade1Page> createState() => _Grade1PageState();
}

class _Grade1PageState extends State<Grade1Page> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Grade 1')),
      body: const Center(child: Text('Content for Grade 1')),
    );
  }
}
