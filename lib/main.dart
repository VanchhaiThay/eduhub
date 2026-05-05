import 'dart:async';
import 'package:eduhub/utils/theme_manager.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:app_links/app_links.dart';
import 'firebase_options.dart';
import 'welcome/welcome.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'components/feature/classtap/class_detail/class_detail_page.dart';
import 'components/feature/assignmentstap/assignment_student_tab.dart';
import 'components/feature/profile/customer_service/customer_service_page.dart';
import 'auth/signin.dart';
import 'auth/signup.dart';
import 'services/time_tracker_service.dart';

// Local notifications plugin
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // 1. Load environment variables FIRST (needed by NewsService + Supabase)
  try {
    await dotenv.load(fileName: ".env");
    debugPrint('[main] .env loaded. keys: ${dotenv.env.keys.toList()}');
  } catch (e) {
    debugPrint('[main] Failed to load .env: $e');
  }

  // 2. Initialize Theme Preference
  await ThemeManager.init();

  // 3. Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // 4. Initialize local notifications
  const AndroidInitializationSettings androidSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initSettings = InitializationSettings(
    android: androidSettings,
  );

  await flutterLocalNotificationsPlugin.initialize(
    settings: initSettings,
    onDidReceiveNotificationResponse: (NotificationResponse response) {
      debugPrint('Notification tapped: ${response.payload}');
    },
  );

  // Create notification channel
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'login_channel',
    'Login Notifications',
    importance: Importance.max,
    description: 'Notifications for login events',
  );

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >()
      ?.createNotificationChannel(channel);

  debugPrint('Notification channel created: login_channel');

  // 5. Initialize Supabase (guarded so missing env doesn't crash the app)
  final supaUrl = dotenv.env['SUPABASE_URL'];
  final supaKey = dotenv.env['SUPABASE_ANON_KEY'];

  if (supaUrl != null && supaKey != null) {
    await Supabase.initialize(url: supaUrl, anonKey: supaKey);
  } else {
    debugPrint('[main] Supabase env missing - skipping Supabase.initialize');
  }

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  final AppLinks _appLinks = AppLinks();

  StreamSubscription<Uri>? _linkSub;

  String? _lastHandledLink;

  final TimeTrackerService _timeTrackerService = TimeTrackerService();

  bool _isTrackingTime = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initDeepLinks();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _linkSub?.cancel();
    // End time tracking when app is disposed
    _endTimeTracking();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        // App going to background or closing - end tracking
        await _endTimeTracking();
        break;
      case AppLifecycleState.resumed:
        // App coming to foreground - start tracking
        await _startTimeTracking();
        break;
      default:
        break;
    }
  }

  Future<void> _startTimeTracking() async {
    if (_isTrackingTime) return;
    try {
      // Check if user is authenticated
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('postgres_user_id');
      if (userId == null) return;
      // Check if there's already an active session
      final activeSession = await _timeTrackerService.getActiveSession();
      if (activeSession != null) {
        _isTrackingTime = true;
        return;
      }
      await _timeTrackerService.startTimeTracking();
      _isTrackingTime = true;
      debugPrint('Time tracking started for user: $userId');
    } catch (e) {
      debugPrint('Failed to start time tracking: $e');
    }
  }

  Future<void> _endTimeTracking() async {
    if (!_isTrackingTime) return;
    try {
      await _timeTrackerService.endTimeTracking();
      _isTrackingTime = false;
      debugPrint('Time tracking ended');
    } catch (e) {
      debugPrint('Failed to end time tracking: $e');
    }
  }

  Future<void> _initDeepLinks() async {
    try {
      // Check for initial deep link from app_links
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        await _handleIncomingLink(initialUri);
      }
    } catch (e) {
      debugPrint('[deep-link] initial link error: $e');
    }
    // Listen to app_links stream
    _linkSub = _appLinks.uriLinkStream.listen((uri) async {
      await _handleIncomingLink(uri);
    });
  }

  Future<void> _handleIncomingLink(Uri uri) async {
    final linkStr = uri.toString();
    if (_lastHandledLink == linkStr) return;
    _lastHandledLink = linkStr;
    // Handle eduhub://, https://eduhub.app/image, and Supabase URLs
    bool isValidLink = false;
    String? classId;
    String? imageUrl;

    if (uri.scheme == 'eduhub' && uri.host == 'image') {
      isValidLink = true;
      classId = uri.queryParameters['classId'];
      imageUrl = uri.queryParameters['imageUrl'];
    } else if (uri.scheme == 'https' &&
        uri.host == 'eduhub.app' &&
        uri.path.startsWith('/image')) {
      isValidLink = true;
      classId = uri.queryParameters['classId'];
      imageUrl = uri.queryParameters['imageUrl'];
    } else if (uri.scheme == 'https' &&
        uri.host == 'vfttstnwcbjcjshjgctr.supabase.co' &&
        uri.path.startsWith(
          '/storage/v1/object/public/photo_message/chat_images/',
        )) {
      isValidLink = true;
      // For Supabase URLs, we need to extract classId from the filename or query parameters
      classId = uri.queryParameters['classId'];
      imageUrl = uri.queryParameters['imageUrl'] ?? uri.toString();
      // If no classId in query params, try to extract from filename
      if (classId == null || classId.isEmpty) {
        final fileName = uri.pathSegments.last;
        // Try to extract classId from filename pattern: timestamp_classId_hash.jpg
        final parts = fileName.split('_');
        if (parts.length >= 2) {
          classId = parts[1];
        }
      }
    }
    // Handle assignment deep links
    else if (uri.scheme == 'https' &&
        uri.host == 'eduhub.app' &&
        uri.path.startsWith('/assignment')) {
      isValidLink = true;
      classId = uri.queryParameters['assignmentId'];
    }

    if (!isValidLink || classId == null || classId.isEmpty) return;
    final currentUser = auth.FirebaseAuth.instance.currentUser;
    final context = rootNavigatorKey.currentContext;
    if (currentUser == null || context == null) return;
    // For assignment deep links, navigate directly to assignment student tab
    if (uri.path.startsWith('/assignment')) {
      rootNavigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (_) =>
              AssignmentStudentTab(assignmentId: classId!, language: 'en'),
        ),
      );
      return;
    }

    final enrollDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .collection('enrolled_classes')
        .doc(classId)
        .get();
    if (!enrollDoc.exists) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Please join this class first to view image messages.',
          ),
          action: SnackBarAction(
            label: 'Join Class',
            textColor: Colors.white,
            onPressed: () {
              // Navigate to class join page or show join dialog
              // You can implement the join functionality here
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Join functionality coming soon!'),
                ),
              );
            },
          ),
        ),
      );
      return;
    }
    final className =
        (enrollDoc.data()?['className'] as String?)?.trim().isNotEmpty == true
        ? enrollDoc.data()!['className'] as String
        : 'Class';
    // Navigate to class detail page
    rootNavigatorKey.currentState?.push(
      MaterialPageRoute(
        builder: (_) =>
            ClassDetailPage(className: className, classId: classId!),
      ),
    );
    // If imageUrl is available, show image preview after a short delay
    if (imageUrl != null && imageUrl.isNotEmpty) {
      Future.delayed(const Duration(milliseconds: 500), () {
        final context = rootNavigatorKey.currentContext;
        if (context != null && context.mounted) {
          _showImagePreview(context, imageUrl!);
        }
      });
    }
  }

  void _showImagePreview(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          fit: StackFit.expand,
          children: [
            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(color: Colors.black.withValues(alpha: 0.9)),
            ),
            Center(child: InteractiveViewer(child: Image.network(imageUrl))),
            Positioned(
              top: 40,
              right: 20,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeManager.themeMode,
      builder: (context, currentMode, child) {
        return MaterialApp(
          navigatorKey: rootNavigatorKey,
          debugShowCheckedModeBanner: false,
          title: 'EduHub',
          themeMode: currentMode,
          theme: ThemeData(
            useMaterial3: true,
            colorSchemeSeed: Colors.teal,
            brightness: Brightness.light,
            scaffoldBackgroundColor: const Color(0xFFF8F9FD),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF38A39D),
              foregroundColor: Colors.white,
            ),
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            colorSchemeSeed: Colors.teal,
            brightness: Brightness.dark,
            scaffoldBackgroundColor: const Color(0xFF121212),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF1F1F1F),
              foregroundColor: Colors.white,
            ),
          ),
          home: const WelcomePage(),
          routes: {
            '/login': (context) => const LoginPage(),
            '/signup': (context) => const SignUpPage(),
            '/customer-service': (context) => const CustomerServicePage(),
          },
        );
      },
    );
  }
}
