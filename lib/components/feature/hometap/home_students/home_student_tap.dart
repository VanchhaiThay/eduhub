import 'dart:async';
import 'package:eduhub/components/feature/coursetap/subject/biology/biology_page.dart';
import 'package:eduhub/components/feature/coursetap/subject/chemistry/chemistry_page.dart';
import 'package:eduhub/components/feature/coursetap/subject/language/language.dart';
import 'package:eduhub/components/feature/coursetap/subject/geography/geography_page.dart';
import 'package:eduhub/components/feature/coursetap/subject/history/history_page.dart';
import 'package:eduhub/components/feature/coursetap/subject/math/math_page.dart';
import 'package:eduhub/components/feature/coursetap/subject/khmer/khmer_page.dart';
import 'package:eduhub/components/feature/coursetap/subject/physics/physics_page.dart';
import 'package:eduhub/components/feature/coursetap/subject/tech/tech_page.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../utils/localization.dart';
import 'package:eduhub/services/news_service.dart';
import 'package:eduhub/services/time_tracker_service.dart';
import 'package:eduhub/constants/app/asset_app.dart';

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
  String? _newsError;
  String? _scholarshipError;

  // Tracking time - accumulated total
  String _totalTimeSpent = "0m 0s";
  int _totalSeconds = 0;

  // Weekly time data for chart
  List<double> _weeklyPercentages = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0];
  bool _isLoadingWeeklyData = true;

  // Real-time update timer
  Timer? _realTimeTimer;

  final List<String> sliderImages = [
    "assets/images/slide1.png",
    "assets/images/slide2.png",
    "assets/images/slide3.png",
  ];

  // <-- Move subjects list here
  final List<Map<String, dynamic>> subjects = [
    {"nameKey": "math", "icon": AppAssets.mathIcon},
    {"nameKey": "history", "icon": AppAssets.historyIcon},
    {"nameKey": "language", "icon": AppAssets.languageIcon},
    {"nameKey": "geography", "icon": AppAssets.geographyIcon},
    {"nameKey": "physics", "icon": AppAssets.physicsIcon},
    {"nameKey": "chemistry", "icon": AppAssets.chemistryIcon},
    {"nameKey": "biology", "icon": AppAssets.biologyIcon},
    {"nameKey": "khmer", "icon": AppAssets.khmerIcon},
    {"nameKey": "tech", "icon": AppAssets.techIcon},
  ];

  // Subject routes
  final Map<String, Widget> subjectRoutes = {
    "math": const MathPage(),
    "history": const HistoryPage(),
    "language": const LanguagePage(),
    "geography": const GeographyPage(),
    "physics": const PhysicsPage(),
    "chemistry": const ChemistryPage(),
    "biology": const BiologyPage(),
    "khmer": const KhmerPage(),
    "tech": const TechPage(),
  };

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _startAutoSlider();
    _loadAllData();
    _startRealTimeUpdates();
  }

  Future<void> _loadAllData() async {
    setState(() {
      _isLoadingNews = true;
      _isLoadingScholarships = true;
      _isLoadingWeeklyData = true;
      _newsError = null;
      _scholarshipError = null;
    });

    final service = NewsService();
    final timeTrackerService = TimeTrackerService();

    // Fetch both in parallel but independently so one failure doesn't
    // break the other.
    final newsFuture = service.fetchCambodiaNews().catchError((e) {
      _newsError = e.toString();
      return <dynamic>[];
    });
    final scholarFuture = service.fetchScholarships().catchError((e) {
      _scholarshipError = e.toString();
      return <dynamic>[];
    });
    final timeFuture = timeTrackerService.getTotalTimeToday().catchError((e) {
      print('Failed to load total time: $e');
      return {'formattedTime': '0m 0s', 'totalSeconds': 0};
    });

    // Try to get weekly data, but fallback to sample data if not available
    final weeklyFuture = _loadWeeklyData().catchError((e) {
      print('Failed to load weekly data: $e');
      // Generate sample data based on current time
      return _generateSampleWeeklyData();
    });

    final results = await Future.wait(
        [newsFuture, scholarFuture, timeFuture, weeklyFuture]);

    final newsList = results[0] as List<dynamic>;
    final scholarshipList = results[1] as List<dynamic>;
    final timeData = results[2] as Map<String, dynamic>;
    final weeklyData = results[3] as List<double>;

    if (mounted) {
      setState(() {
        _newsList = newsList;
        _scholarshipList = scholarshipList;
        _totalTimeSpent = timeData['formattedTime'] ?? '0m 0s';
        _totalSeconds = timeData['totalSeconds'] ?? 0;
        _weeklyPercentages = weeklyData;
        _isLoadingNews = false;
        _isLoadingScholarships = false;
        _isLoadingWeeklyData = false;
      });
    }
  }

  Future<void> _refreshTimeData() async {
    try {
      final timeTrackerService = TimeTrackerService();
      final timeData = await timeTrackerService.getTotalTimeToday();

      if (mounted) {
        setState(() {
          _totalTimeSpent = timeData['formattedTime'] ?? '0m 0s';
          _totalSeconds = timeData['totalSeconds'] ?? 0;
        });
      }
    } catch (e) {
      print('Failed to refresh time data: $e');
    }
  }

  Future<void> _refreshTimeDataWithFeedback() async {
    // Show loading indicator
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              SizedBox(width: 12),
              Text("Refreshing time tracker..."),
            ],
          ),
          duration: Duration(seconds: 2),
          backgroundColor: Color(0xFF38A39D),
        ),
      );
    }

    try {
      final timeTrackerService = TimeTrackerService();
      final timeData = await timeTrackerService.getTotalTimeToday();

      if (mounted) {
        setState(() {
          _totalTimeSpent = timeData['formattedTime'] ?? '0m 0s';
          _totalSeconds = timeData['totalSeconds'] ?? 0;
        });

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                Text("Time tracker refreshed! $_totalTimeSpent"),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                Text("Failed to refresh: $e"),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
      print('Failed to refresh time data: $e');
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
    _realTimeTimer?.cancel(); // Cancel real-time timer
    super.dispose();
  }

  // Start real-time updates for current day's progress
  void _startRealTimeUpdates() {
    _realTimeTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted) {
        _refreshTimeData();
      }
    });
  }

  // Calculate today's percentage of 24-hour day
  double _getTodayPercentage() {
    return (_totalSeconds / 86400) * 100; // 86400 seconds = 24 hours
  }

  // Helper method to get day names
  String _getWeekDay(int index) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    if (index >= 0 && index < days.length) {
      return days[index];
    }
    return '';
  }

  // Load weekly time tracking data
  Future<List<double>> _loadWeeklyData() async {
    try {
      final timeTrackerService = TimeTrackerService();
      final weeklyData = await timeTrackerService.getWeeklyTimeData();

      // Convert time data to percentages (24 hours = 100%)
      List<double> percentages = [];
      if (weeklyData['dailyData'] != null) {
        for (var dayData in weeklyData['dailyData']) {
          final seconds = dayData['totalSeconds'] ?? 0;
          final percentage =
              (seconds / 86400) * 100; // 86400 seconds = 24 hours
          percentages.add(percentage.clamp(0.0, 100.0));
        }
      }

      // Ensure we have 7 days
      while (percentages.length < 7) {
        percentages.add(0.0);
      }

      return percentages.take(7).toList();
    } catch (e) {
      throw e;
    }
  }

  // Generate sample weekly data based on current time
  List<double> _generateSampleWeeklyData() {
    final now = DateTime.now();
    final currentDay = now.weekday - 1; // Monday = 0, Sunday = 6

    return List.generate(7, (index) {
      if (index == currentDay) {
        // Current day: use actual time percentage
        return (_totalSeconds / 86400) * 100;
      } else if (index < currentDay) {
        // Past days: generate realistic data
        return (index + 1) * 8 + (index % 3) * 5;
      } else {
        // Future days: 0 for now
        return 0.0;
      }
    });
  }

  List<Map<String, dynamic>> _getFilteredSubjects() {
    if (_searchQuery.isEmpty) {
      return isExpanded ? subjects : subjects.take(6).toList();
    }

    return subjects.where((subject) {
      String localizedName = Localization.text(
        widget.language,
        subject['nameKey'],
      ).toLowerCase();

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
              Localization.text(widget.language, "schrolarshipOpportunities"),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.grey[800],
              ),
            ),
            const Icon(Icons.star, color: Colors.amber, size: 20),
          ],
        ),
        const SizedBox(height: 15),
        _isLoadingScholarships
            ? const Center(child: CircularProgressIndicator())
            : _scholarshipList.isEmpty
                ? _buildEmptyState(
                    _scholarshipError != null
                        ? "Couldn't load scholarships. Tap to retry."
                        : "No scholarship updates available. Tap to retry.",
                  )
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
          boxShadow:
              isDark ? [] : [BoxShadow(color: Colors.black12, blurRadius: 5)],
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
                style: TextStyle(
                  color: Color(0xFF38A39D),
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
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
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.grey[800],
          ),
        ),
        const SizedBox(height: 15),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? Colors.grey[900] : Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: isDark
                ? []
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                    ),
                  ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    Localization.text(
                      widget.language,
                      "Total Course Completion",
                    ),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Bar Chart for Learning Progress
              SizedBox(
                height: 200,
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: 100,
                    barTouchData: BarTouchData(
                      touchTooltipData: BarTouchTooltipData(
                        getTooltipColor: (_) => Colors.grey[800]!,
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          final day = _getWeekDay(group.x.toInt());
                          return BarTooltipItem(
                            '$day: ${rod.toY.round()}%',
                            const TextStyle(color: Colors.white, fontSize: 12),
                          );
                        },
                      ),
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            final day = _getWeekDay(value.toInt());
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                day,
                                style: TextStyle(
                                  fontSize: 10,
                                  color:
                                      isDark ? Colors.white70 : Colors.black87,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              '${value.toInt()}%',
                              style: TextStyle(
                                fontSize: 10,
                                color: isDark ? Colors.white70 : Colors.black87,
                              ),
                            );
                          },
                        ),
                      ),
                      topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                    ),
                    borderData: FlBorderData(show: false),
                    barGroups: List.generate(7, (index) {
                      // Use real time tracking data as percentage of 24-hour day
                      // For current day, use real-time percentage
                      final currentDayIndex =
                          DateTime.now().weekday - 1; // Monday = 0, Sunday = 6
                      final percentage = (index == currentDayIndex)
                          ? _getTodayPercentage()
                          : _weeklyPercentages[index];
                      return BarChartGroupData(
                        x: index,
                        barRods: [
                          BarChartRodData(
                            toY: percentage.clamp(0.0, 100.0),
                            color: (index == currentDayIndex)
                                ? const Color(
                                    0xFF2E7D32) // Highlight current day
                                : const Color(0xFF38A39D),
                            width: 12,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(6),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Accumulated Time Spent Display
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF38A39D).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.timer,
                          color: Color(0xFF38A39D),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "Total Time Spent Today",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white70 : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              _totalTimeSpent,
                              style: const TextStyle(
                                color: Color(0xFF38A39D),
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              '${_getTodayPercentage().toStringAsFixed(1)}%',
                              style: const TextStyle(
                                color: Color(0xFF38A39D),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 8),
                        // Refresh button
                        GestureDetector(
                          onTap: _refreshTimeData,
                          onDoubleTap: _refreshTimeDataWithFeedback,
                          child: Icon(
                            Icons.refresh,
                            size: 16,
                            color: Color(0xFF38A39D),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
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
              Localization.text(widget.language, "news&event"),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.grey[800],
              ),
            ),
            const Text(
              "See All",
              style: TextStyle(color: Color(0xFF38A39D), fontSize: 14),
            ),
          ],
        ),
        const SizedBox(height: 15),
        SizedBox(
          height: 130,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _buildEventCard(
                "Phnom Penh Workshop",
                "Feb 20, 2026",
                Icons.location_on,
                Colors.blueAccent,
                isDark,
              ),
              _buildEventCard(
                "National Exam Prep",
                "Mar 10, 2026",
                Icons.edit_note,
                Colors.purpleAccent,
                isDark,
              ),
            ],
          ),
        ),
        const SizedBox(height: 25),
        Text(
          Localization.text(widget.language, "LatesteducationNews"),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 12),
        _isLoadingNews
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(),
                ),
              )
            : _newsList.isEmpty
                ? _buildEmptyState(
                    _newsError != null
                        ? "Couldn't load news. Tap to retry."
                        : "No recent news found for Cambodia. Tap to retry.",
                  )
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

  Widget _buildEventCard(
    String title,
    String date,
    IconData icon,
    Color color,
    bool isDark,
  ) {
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
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            date,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.white60 : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewsTile(
    String title,
    String time,
    String? imageUrl,
    String? articleUrl,
    bool isDark,
  ) {
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
                width: 55,
                height: 55,
                color: Colors.grey[300],
                child: imageUrl != null
                    ? Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (c, e, s) => const Icon(Icons.newspaper),
                      )
                    : const Icon(Icons.newspaper, color: Color(0xFF38A39D)),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    time,
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, size: 18, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return InkWell(
      onTap: _loadAllData,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF38A39D).withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF38A39D).withOpacity(0.3)),
        ),
        child: Row(
          children: [
            const Icon(Icons.refresh, size: 18, color: Color(0xFF38A39D)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontSize: 13, color: Color(0xFF38A39D)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  TextStyle _chartTextStyle() => const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      );

  Widget _buildLegend(Color color, String text, bool isDark) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: isDark ? Colors.white60 : Colors.black54,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchAndHeader(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          Localization.text(widget.language, "allsubjcts"),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.grey[800],
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _searchController,
          onChanged: (value) => setState(() => _searchQuery = value),
          decoration: InputDecoration(
            hintText: Localization.text(widget.language, "searchsubjects"),
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none,
            ),
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
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 10,
        mainAxisExtent: 95,
      ),
      itemBuilder: (context, index) {
        final subject = filteredList[index];

        return InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            final page = subjectRoutes[subject['nameKey']];
            if (page != null) {
              Navigator.push(context, MaterialPageRoute(builder: (_) => page));
            }
          },
          child: Column(
            children: [
              Container(
                height: 60,
                width: 60,
                decoration: BoxDecoration(
                  color: const Color(0xFF38A39D).withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Image.asset(
                    subject['icon'],
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.image_not_supported,
                      color: Color(0xFF38A39D),
                      size: 28,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                Localization.text(widget.language, subject['nameKey']),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white70 : Colors.grey[800],
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWelcomeCard(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1E3A3A), const Color(0xFF2D4F4F)]
              : [const Color(0xffACFBFF), const Color(0xffD8FEFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  Localization.text(widget.language, "welcomeTitle"),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  Localization.text(widget.language, "welcomeDesc"),
                  style: const TextStyle(fontSize: 12),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                TextButton(
                  onPressed: widget.onLearnMore,
                  child: Text(
                    Localization.text(widget.language, "learnmore"),
                    style: const TextStyle(
                      color: Color(0xFF38A39D),
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Image.asset(
              "assets/images/learning.png",
              height: 60,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.broken_image, size: 60),
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
          height: 150,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (int page) => setState(() => _currentPage = page),
            itemCount: sliderImages.length,
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Colors.grey[300],
                ),
                // Updated code (Actually loads the file)
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.asset(
                    sliderImages[index],
                    fit: BoxFit.cover,
                    // This handles errors if the file is missing
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.broken_image),
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
          Text(
            isExpanded
                ? Localization.text(widget.language, "seeless")
                : Localization.text(widget.language, "seemore"),
            style: const TextStyle(color: Color(0xFF38A39D)),
          ),
          Icon(
            isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
            color: const Color(0xFF38A39D),
          ),
        ],
      ),
    );
  }
}
