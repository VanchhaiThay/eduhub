import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../../../utils/localization.dart';

// --- NEWS SERVICE ---
class NewsService {
  final String _apiKey = "pub_73c66af2943a48d1b292611f9280af07";

  // Fetch general education news in Cambodia
  Future<List<dynamic>> fetchCambodiaNews() async {
    final url = "https://newsdata.io/api/1/news?apikey=$_apiKey&country=kh&category=education";
    return _handleFetch(url);
  }

  // Fetch global/Cambodian scholarship news
  Future<List<dynamic>> fetchScholarships() async {
    // We use 'q=scholarship' to specifically target financial aid opportunities
    final url = "https://newsdata.io/api/1/news?apikey=$_apiKey&q=scholarship&language=en";
    return _handleFetch(url);
  }

  Future<List<dynamic>> _handleFetch(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['results'] ?? [];
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}

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

  List<dynamic> _newsList = [];
  List<dynamic> _scholarshipList = []; // Added for scholarships
  bool _isLoadingNews = true;
  bool _isLoadingScholarships = true; // Added for scholarships

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
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    setState(() {
      _isLoadingNews = true;
      _isLoadingScholarships = true;
    });
    
    // Fetch both in parallel
    final results = await Future.wait([
      NewsService().fetchCambodiaNews(),
      NewsService().fetchScholarships(),
    ]);

    if (mounted) {
      setState(() {
        _newsList = results[0];
        _scholarshipList = results[1];
        _isLoadingNews = false;
        _isLoadingScholarships = false;
      });
    }
  }

  Future<void> _launchNewsURL(String? urlString) async {
    if (urlString == null || urlString.isEmpty) return;
    final Uri url = Uri.parse(urlString);
    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        throw Exception('Could not launch $url');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Could not open the article.")),
        );
      }
    }
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
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return RefreshIndicator(
      onRefresh: _loadAllData,
      child: SingleChildScrollView(
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
            const SizedBox(height: 30),
            _buildStatisticsSection(isDark),
            const SizedBox(height: 30),
            _buildScholarshipSection(isDark), // NEW: Scholarship Section
            const SizedBox(height: 30),
            _buildNewsAndEvents(isDark),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // --- NEW SCHOLARSHIP SECTION ---
  Widget _buildScholarshipSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Scholarship Opportunities",
              style: TextStyle(
                fontSize: 18, 
                fontWeight: FontWeight.bold, 
                color: isDark ? Colors.white : Colors.grey[800]
              ),
            ),
            const Icon(Icons.star, color: Colors.amber, size: 20),
          ],
        ),
        const SizedBox(height: 15),
        _isLoadingScholarships 
          ? const Center(child: CircularProgressIndicator())
          : _scholarshipList.isEmpty
            ? const Text("No scholarship updates available.")
            : SizedBox(
                height: 160,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _scholarshipList.take(6).length,
                  itemBuilder: (context, index) {
                    final item = _scholarshipList[index];
                    return _buildScholarshipCard(item, isDark);
                  },
                ),
              ),
      ],
    );
  }

  Widget _buildScholarshipCard(dynamic item, bool isDark) {
    return InkWell(
      onTap: () => _launchNewsURL(item['link']),
      child: Container(
        width: 240,
        margin: const EdgeInsets.only(right: 15),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[900] : Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: const Color(0xFF38A39D).withOpacity(0.3)),
          boxShadow: isDark ? [] : [BoxShadow(color: Colors.black12, blurRadius: 5)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item['title'] ?? "Scholarship Details",
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            const Spacer(),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 12, color: Colors.grey),
                const SizedBox(width: 5),
                Text(
                  item['pubDate']?.split(" ")[0] ?? "Recent",
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF38A39D).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                "View Details",
                style: TextStyle(color: Color(0xFF38A39D), fontSize: 11, fontWeight: FontWeight.bold),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          Localization.text(widget.language, "learningProgress"),
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.grey[800]),
        ),
        const SizedBox(height: 15),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? Colors.grey[900] : Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Total Course Completion", style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white70 : Colors.black87)),
                  const Text("75%", style: TextStyle(color: Color(0xFF38A39D), fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: 0.75,
                  minHeight: 10,
                  backgroundColor: const Color(0xFF38A39D).withOpacity(0.1),
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF38A39D)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Container(
          height: 200,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? Colors.grey[900] : Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: isDark ? Border.all(color: Colors.white10) : null,
          ),
          child: Row(
            children: [
              Expanded(
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: 35,
                    sections: [
                      PieChartSectionData(value: 45, title: '45%', color: const Color(0xFF38A39D), radius: 45, titleStyle: _chartTextStyle()),
                      PieChartSectionData(value: 30, title: '30%', color: Colors.amber, radius: 45, titleStyle: _chartTextStyle()),
                      PieChartSectionData(value: 25, title: '25%', color: Colors.orangeAccent, radius: 45, titleStyle: _chartTextStyle()),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLegend(const Color(0xFF38A39D), "Lesson", isDark),
                  const SizedBox(height: 10),
                  _buildLegend(Colors.amber, "Time", isDark),
                  const SizedBox(height: 10),
                  _buildLegend(Colors.orangeAccent, "Complete", isDark),
                ],
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNewsAndEvents(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "News & Events",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.grey[800]),
            ),
            const Text("See All", style: TextStyle(color: Color(0xFF38A39D), fontSize: 14)),
          ],
        ),
        const SizedBox(height: 15),
        SizedBox(
          height: 130,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _buildEventCard("Phnom Penh Workshop", "Feb 20, 2026", Icons.location_on, Colors.blueAccent, isDark),
              _buildEventCard("National Exam Prep", "Mar 10, 2026", Icons.edit_note, Colors.purpleAccent, isDark),
            ],
          ),
        ),
        const SizedBox(height: 25),
        const Text("Latest Education News", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 12),
        _isLoadingNews 
          ? const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator())) 
          : _newsList.isEmpty 
            ? const Text("No recent news found for Cambodia.")
            : Column(
                children: _newsList.take(5).map((news) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildNewsTile(
                      news['title'] ?? "No Title",
                      news['pubDate'] ?? "Today",
                      news['image_url'],
                      news['link'],
                      isDark,
                    ),
                  );
                }).toList(),
              ),
      ],
    );
  }

  Widget _buildEventCard(String title, String date, IconData icon, Color color, bool isDark) {
    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: color.withOpacity(isDark ? 0.2 : 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const Spacer(),
          Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87), maxLines: 1, overflow: TextOverflow.ellipsis),
          Text(date, style: TextStyle(fontSize: 12, color: isDark ? Colors.white60 : Colors.black54)),
        ],
      ),
    );
  }

  Widget _buildNewsTile(String title, String time, String? imageUrl, String? articleUrl, bool isDark) {
    return InkWell(
      onTap: () => _launchNewsURL(articleUrl),
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[900] : Colors.grey[100],
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: 55, height: 55,
                color: Colors.grey[300],
                child: imageUrl != null 
                  ? Image.network(imageUrl, fit: BoxFit.cover, errorBuilder: (c, e, s) => const Icon(Icons.newspaper))
                  : const Icon(Icons.newspaper, color: Color(0xFF38A39D)),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: isDark ? Colors.white : Colors.black87), maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text(time, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, size: 18, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  TextStyle _chartTextStyle() => const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white);

  Widget _buildLegend(Color color, String text, bool isDark) {
    return Row(
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Text(text, style: TextStyle(fontSize: 12, color: isDark ? Colors.white60 : Colors.black54)),
      ],
    );
  }

  Widget _buildSearchAndHeader(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          Localization.text(widget.language, "allsubjcts"),
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.grey[800]),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _searchController,
          onChanged: (value) => setState(() => _searchQuery = value),
          decoration: InputDecoration(
            hintText: Localization.text(widget.language, "searchsubjects"),
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
            filled: true,
            fillColor: isDark ? Colors.grey[900] : Colors.grey[200],
          ),
        ),
      ],
    );
  }

  Widget _buildSubjectGrid(bool isDark) {
    final filteredList = _getFilteredSubjects();
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: filteredList.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, mainAxisSpacing: 10),
      itemBuilder: (context, index) {
        return Column(
          children: [
            Container(
              height: 60, width: 60,
              decoration: BoxDecoration(color: const Color(0xFF38A39D).withOpacity(0.15), shape: BoxShape.circle),
              child: Icon(filteredList[index]['icon'], color: const Color(0xFF38A39D), size: 28),
            ),
            const SizedBox(height: 6),
            Text(
              Localization.text(widget.language, filteredList[index]['nameKey']),
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isDark ? Colors.white70 : Colors.grey[800]),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
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
          colors: isDark ? [const Color(0xFF1E3A3A), const Color(0xFF2D4F4F)] : [const Color(0xffACFBFF), const Color(0xffD8FEFF)],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          Expanded(
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(Localization.text(widget.language, "welcomeTitle"), style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(Localization.text(widget.language, "welcomeDesc"), style: const TextStyle(fontSize: 13)),
                TextButton(onPressed: widget.onLearnMore, child: const Text("Learn More", style: TextStyle(color: Color(0xFF38A39D), fontWeight: FontWeight.bold))),
              ],
            ),
          ),
          const Expanded(flex: 3, child: Icon(Icons.school, size: 70, color: Color(0xFF38A39D))),
        ],
      ),
    );
  }

  Widget _buildImageSlider(bool isDark) {
    return Column(
      children: [
        SizedBox(
          height: 150,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (int page) => setState(() => _currentPage = page),
            itemCount: sliderImages.length,
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 5),
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(15), color: Colors.grey[300]),
                // Updated code (Actually loads the file)
child: ClipRRect(
  borderRadius: BorderRadius.circular(15),
  child: Image.asset(
    sliderImages[index],
    fit: BoxFit.cover,
    // This handles errors if the file is missing
    errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image),
  ),
),
              );
            },
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
          Text(isExpanded ? "See Less" : "See More", style: const TextStyle(color: Color(0xFF38A39D))),
          Icon(isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, color: const Color(0xFF38A39D)),
        ],
      ),
    );
  }
}