import 'package:flutter/material.dart';
import '../../utils/localization.dart';

class HomeStudentTab extends StatelessWidget {
  final String language;

  const HomeStudentTab({super.key, required this.language});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        Localization.text(language, 'homeScreenStudent'),
        style: const TextStyle(fontSize: 22),
      ),
    );
  }
}
