import 'package:flutter/material.dart';

class MathPage extends StatefulWidget {
  const MathPage({super.key});

  @override
  State<MathPage> createState() => _MathPageState();
}

class _MaterialColorData {
  final String title;
  final Color color;
  final IconData icon;

  _MaterialColorData(this.title, this.color, this.icon);
}

class _MathPageState extends State<MathPage> {
  // Define a list of colors and icons to make each grade unique
  final List<_MaterialColorData> grades = [
    _MaterialColorData('Grade 1', Colors.redAccent, Icons.filter_1),
    _MaterialColorData('Grade 2', Colors.orangeAccent, Icons.filter_2),
    _MaterialColorData('Grade 3', Colors.amber, Icons.filter_3),
    _MaterialColorData('Grade 4', Colors.greenAccent, Icons.filter_4),
    _MaterialColorData('Grade 5', Colors.teal, Icons.filter_5),
    _MaterialColorData('Grade 6', Colors.blueAccent, Icons.filter_6),
    _MaterialColorData('Grade 7', Colors.indigoAccent, Icons.filter_7),
    _MaterialColorData('Grade 8', Colors.purpleAccent, Icons.filter_8),
    _MaterialColorData('Grade 9', Colors.pinkAccent, Icons.filter_9),
    _MaterialColorData('Grade 10', Colors.deepOrange, Icons.school),
    _MaterialColorData('Grade 11', Colors.cyan, Icons.functions),
    _MaterialColorData('Grade 12', Colors.blueGrey, Icons.calculate),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          "Mathematics Portal",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.teal[700],
        elevation: 4,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          itemCount: grades.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // 2 cards per row
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.1, // Adjust height/width ratio
          ),
          itemBuilder: (context, index) {
            final grade = grades[index];
            return _buildGradeCard(grade);
          },
        ),
      ),
    );
  }

  Widget _buildGradeCard(_MaterialColorData grade) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        onTap: () {
          // Add your navigation logic here
          print("Selected ${grade.title}");
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                grade.color.withOpacity(0.8),
                grade.color,
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                grade.icon,
                size: 50,
                color: Colors.white,
              ),
              const SizedBox(height: 12),
              Text(
                grade.title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  "View Lessons",
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}