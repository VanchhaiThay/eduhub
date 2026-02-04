import 'dart:async';
import 'package:flutter/material.dart';
import '../../../utils/localization.dart';

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
  late PageController _pageController;
  int _currentPage = 0;
  Timer? _timer;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  final List<String> sliderImages = [
    "assets/images/slide1.png",
    "assets/images/slide2.png",
    "assets/images/slide3.png",
  ];

  final List<Map<String, dynamic>> subjects = [
    {"nameKey": "math", "icon": Icons.calculate},
    {"nameKey": "science", "icon": Icons.science},
    {"nameKey": "history", "icon": Icons.history_edu},
    {"nameKey": "english", "icon": Icons.translate},
    {"nameKey": "geography", "icon": Icons.public},
    {"nameKey": "physics", "icon": Icons.wb_iridescent},
    {"nameKey": "chemistry", "icon": Icons.biotech},
    {"nameKey": "biology", "icon": Icons.psychology},
    {"nameKey": "art", "icon": Icons.palette},
    {"nameKey": "music", "icon": Icons.music_note},
    {"nameKey": "tech", "icon": Icons.computer},
    {"nameKey": "sports", "icon": Icons.sports_basketball},
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _startAutoSlider();
  }

  void _startAutoSlider() {
    _timer = Timer.periodic(const Duration(seconds: 3), (Timer timer) {
      if (_pageController.hasClients) {
        int nextPage = (_currentPage + 1) % sliderImages.length;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _getFilteredSubjects() {
    if (_searchQuery.isEmpty) {
      return isExpanded ? subjects : subjects.take(6).toList();
    }
    return subjects.where((subject) {
      String localizedName = Localization.text(widget.language, subject['nameKey']).toLowerCase();
      return localizedName.contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    // Detect if Dark Mode is active
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        children: [
          _buildWelcomeCard(isDark),
          const SizedBox(height: 20),
          _buildImageSlider(isDark),
          const SizedBox(height: 25),
          _buildSearchAndHeader(isDark),
          const SizedBox(height: 20),
          _buildSubjectGrid(isDark),
          if (_searchQuery.isEmpty) _buildSeeMoreButton(),
        ],
      ),
    );
  }

  Widget _buildSearchAndHeader(bool isDark) {
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
              // Adapts text color for light/dark
              color: isDark ? Colors.white : Colors.grey[800],
            ),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _searchController,
          onChanged: (value) => setState(() => _searchQuery = value),
          decoration: InputDecoration(
            hintText: Localization.text(widget.language, "searchsubjects"),
            prefixIcon: const Icon(Icons.search),
            suffixIcon: _searchQuery.isNotEmpty 
                ? IconButton(
                    icon: const Icon(Icons.clear), 
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _searchQuery = "");
                    }) 
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none,
            ),
            filled: true,
            // Darker fill for search bar in dark mode
            fillColor: isDark ? Colors.grey[900] : Colors.grey[200],
          ),
        ),
      ],
    );
  }

  Widget _buildSubjectGrid(bool isDark) {
    final filteredList = _getFilteredSubjects();

    if (filteredList.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(20.0),
        child: Text(
          "No subjects found.",
          style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600]),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: filteredList.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 0.8,
      ),
      itemBuilder: (context, index) {
        return Column(
          children: [
            Container(
              height: 65, width: 65,
              decoration: BoxDecoration(
                // Opacity remains 0.1, color matches brand teal
                color: const Color(0xFF38A39D).withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                filteredList[index]['icon'],
                color: const Color(0xFF38A39D),
                size: 30,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              Localization.text(widget.language, filteredList[index]['nameKey']),
              style: TextStyle(
                fontSize: 13, 
                fontWeight: FontWeight.w600, 
                color: isDark ? Colors.white70 : Colors.grey[800],
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ],
        );
      },
    );
  }

  Widget _buildWelcomeCard(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          // Adjust gradient for dark mode to be less blinding
          colors: isDark 
            ? [const Color(0xFF1E3A3A), const Color(0xFF2D4F4F)]
            : [const Color(0xffACFBFF), const Color(0xffD8FEFF)],
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
                      style: TextStyle(
                        fontSize: 20, 
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      Localization.text(widget.language, "welcomeDesc"),
                      style: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
                    ),
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
            child: Text(
              Localization.text(widget.language, "learnmore"),
              style: const TextStyle(color: Color(0xFF38A39D), fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageSlider(bool isDark) {
    return Column(
      children: [
        SizedBox(
          height: 160,
          width: double.infinity,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (int page) => setState(() => _currentPage = page),
            itemCount: sliderImages.length,
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  // Border for slider in dark mode helps it pop
                  border: isDark ? Border.all(color: Colors.white10) : null,
                  image: DecorationImage(
                    image: AssetImage(sliderImages[index]),
                    fit: BoxFit.cover,
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            sliderImages.length,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              height: 8,
              width: _currentPage == index ? 20 : 8,
              decoration: BoxDecoration(
                color: _currentPage == index 
                    ? const Color(0xFF38A39D) 
                    : (isDark ? Colors.white24 : Colors.grey.withOpacity(0.5)),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSeeMoreButton() {
    return TextButton(
      onPressed: () => setState(() => isExpanded = !isExpanded),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            isExpanded 
              ? Localization.text(widget.language, "seeLess") 
              : Localization.text(widget.language, "seeMore"),
            style: const TextStyle(color: Color(0xFF38A39D), fontWeight: FontWeight.bold),
          ),
          Icon(
            isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, 
            color: const Color(0xFF38A39D)
          ),
        ],
      ),
    );
  }
}