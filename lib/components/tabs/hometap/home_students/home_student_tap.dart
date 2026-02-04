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

  // Search logic variables
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
    _searchController.dispose(); // Clean up controller
    super.dispose();
  }

  // Logic to filter subjects based on localized text
  List<Map<String, dynamic>> _getFilteredSubjects() {
    if (_searchQuery.isEmpty) {
      return isExpanded ? subjects : subjects.take(6).toList();
    }

    return subjects.where((subject) {
      // We get the translated name based on the current language
      String localizedName = Localization.text(widget.language, subject['nameKey']).toLowerCase();
      return localizedName.contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        children: [
          _buildWelcomeCard(),
          const SizedBox(height: 20),
          _buildImageSlider(),
          const SizedBox(height: 25),
          _buildSearchAndHeader(),
          const SizedBox(height: 20),
          _buildSubjectGrid(),
          // Hide "See More" button if user is searching
          if (_searchQuery.isEmpty) _buildSeeMoreButton(),
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
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[800]),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _searchController,
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
            });
          },
          decoration: InputDecoration(
            hintText: Localization.text(widget.language, "searchsubjects"),
            prefixIcon: const Icon(Icons.search, color: Colors.grey),
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
            fillColor: Colors.grey[200],
          ),
        ),
      ],
    );
  }

  Widget _buildSubjectGrid() {
    final filteredList = _getFilteredSubjects();

    if (filteredList.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(20.0),
        child: Text("No subjects found."),
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
        childAspectRatio: 0.8, // Adjusted to prevent text overflow
      ),
      itemBuilder: (context, index) {
        return Column(
          children: [
            Container(
              height: 65, width: 65,
              decoration: BoxDecoration(
                color: const Color(0xFF38A39D).withOpacity(0.1),
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
                color: Colors.grey[800]
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

  // Welcome card and Image slider remain the same
  Widget _buildWelcomeCard() {
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

  Widget _buildImageSlider() {
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
                color: _currentPage == index ? const Color(0xFF38A39D) : Colors.grey.withOpacity(0.5),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      ],
    );
  }
}