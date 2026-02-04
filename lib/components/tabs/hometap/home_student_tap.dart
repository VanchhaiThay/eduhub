import 'package:flutter/material.dart';
import '../../utils/localization.dart';

class HomeStudentTab extends StatefulWidget {
  final String language;
  final VoidCallback onLearnMore;

  const HomeStudentTab({
    super.key,
    required this.language,
    required this.onLearnMore,
  });

  @override
  State<HomeStudentTab> createState() => _HomeStudentTabState();
}

class _HomeStudentTabState extends State<HomeStudentTab> {
  bool isExpanded = false;

  // List of 12 subjects with corresponding icons
  final List<Map<String, dynamic>> subjects = [
    {"name": "Math", "icon": Icons.calculate},
    {"name": "Science", "icon": Icons.science},
    {"name": "History", "icon": Icons.history_edu},
    {"name": "English", "icon": Icons.translate},
    {"name": "Geography", "icon": Icons.public},
    {"name": "Physics", "icon": Icons.wb_iridescent},
    {"name": "Chemistry", "icon": Icons.biotech},
    {"name": "Biology", "icon": Icons.psychology},
    {"name": "Art", "icon": Icons.palette},
    {"name": "Music", "icon": Icons.music_note},
    {"name": "Tech", "icon": Icons.computer},
    {"name": "Sports", "icon": Icons.sports_basketball},
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        children: [
          _buildWelcomeCard(context),
          const SizedBox(height: 25),
          _buildSearchAndHeader(),
          const SizedBox(height: 20),
          _buildSubjectGrid(),
          _buildSeeMoreButton(),
        ],
      ),
    );
  }

  Widget _buildSearchAndHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Text(
            Localization.text(widget.language, "allsubjcts"),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          decoration: InputDecoration(
            hintText: Localization.text(widget.language, "searchsubjects"),
            prefixIcon: const Icon(Icons.search, color: Colors.grey),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Colors.grey[200],
          ),
        ),
      ],
    );
  }

  Widget _buildSubjectGrid() {
    // Show only 6 or all 12
    final displayList = isExpanded ? subjects : subjects.take(6).toList();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: displayList.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, // 3 items per row
      ),
      itemBuilder: (context, index) {
        return Column(
          children: [
            // Circular Icon Container
            Container(
              height: 65,
              width: 65,
              decoration: BoxDecoration(
                color: const Color(0xFF38A39D).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                displayList[index]['icon'],
                color: const Color(0xFF38A39D),
                size: 30,
              ),
            ),
            const SizedBox(height: 8),
            // Subject Name
            Text(
              displayList[index]['name'],
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        );
      },
    );
  }

  Widget _buildSeeMoreButton() {
    return TextButton(
      onPressed: () => setState(() => isExpanded = !isExpanded),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            isExpanded ? "See Less" : "See More",
            style: const TextStyle(
              color: Color(0xFF38A39D),
              fontWeight: FontWeight.bold,
            ),
          ),
          Icon(
            isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
            color: const Color(0xFF38A39D),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeCard(BuildContext context) {
    // ... (Keep your existing _buildWelcomeCard implementation)
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xffACFBFF), Color(0xffD8FEFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                flex: 5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      Localization.text(widget.language, "welcomeTitle"),
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(Localization.text(widget.language, "welcomeDesc")),
                  ],
                ),
              ),
              Expanded(
                flex: 3,
                child: Image.asset("assets/images/learning.png", height: 80),
              ),
            ],
          ),
          TextButton(
            onPressed: widget.onLearnMore,
            child: Text(Localization.text(widget.language, "learnmore")),
          ),
        ],
      ),
    );
  }
}