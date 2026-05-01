import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';

/// NewsService - wraps the newsdata.io API.
///
/// Provides:
///  - fetchCambodiaNews()  : education news relevant to Cambodia (with
///    fallback to regional Asian education news if empty)
///  - fetchScholarships()  : scholarship / education grant news
class NewsService {
  // Hard-coded fallback API key so the app still works if dotenv fails
  // to load (e.g. .env not bundled, or loaded too late in main()).
  static const String _fallbackApiKey = 'pub_73c66af2943a48d1b292611f9280af07';

  static String get apiKey {
    try {
      final fromEnv = dotenv.env['NEWS_API_KEY'];
      if (fromEnv != null && fromEnv.trim().isNotEmpty) {
        return fromEnv.trim();
      }
    } catch (_) {
      // dotenv not initialised - fall through to fallback.
    }
    return _fallbackApiKey;
  }

  /// Simple in-memory cache to avoid re-hitting the API on every rebuild.
  static final Map<String, _CachedResponse> _cache = {};
  static const Duration _cacheTtl = Duration(minutes: 10);

  /// Education news for Cambodia. Falls back to regional news if nothing
  /// specific to Cambodia is returned.
  Future<List<dynamic>> fetchCambodiaNews() async {
    final primary = await _fetch(
      '$newsApiBaseUrl?apikey=$apiKey$newsCambodiaQuery',
      label: 'Cambodia news',
    );
    if (primary.isNotEmpty) return primary;

    debugPrint('[NewsService] Cambodia news empty - trying regional fallback');
    return _fetch(
      '$newsApiBaseUrl?apikey=$apiKey$newsAsiaEducationQuery',
      label: 'Regional education news',
    );
  }

  /// Scholarship / education grant news.
  Future<List<dynamic>> fetchScholarships() async {
    final results = await _fetch(
      '$newsApiBaseUrl?apikey=$apiKey$newsScholarshipQuery',
      label: 'Scholarships',
    );

    // Extra filter: keep only items whose title/description actually
    // mention scholarship-related keywords (the API's `q` is fuzzy).
    const keywords = [
      'scholarship',
      'fellowship',
      'grant',
      'bursary',
      'financial aid',
      'student aid',
    ];
    final filtered = results.where((item) {
      final title = (item['title'] ?? '').toString().toLowerCase();
      final desc = (item['description'] ?? '').toString().toLowerCase();
      return keywords.any((k) => title.contains(k) || desc.contains(k));
    }).toList();

    // If filtering removes everything, return the raw results so the UI
    // still shows something useful.
    return filtered.isNotEmpty ? filtered : results;
  }

  // ---------------------------------------------------------------------------
  // Internal
  // ---------------------------------------------------------------------------

  Future<List<dynamic>> _fetch(String url, {required String label}) async {
    // Cache hit?
    final cached = _cache[url];
    if (cached != null && !cached.isExpired) {
      debugPrint('[NewsService] $label - cache hit (${cached.data.length})');
      return cached.data;
    }

    try {
      debugPrint('[NewsService] $label - GET ${_sanitize(url)}');
      final response = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 15));

      debugPrint('[NewsService] $label - status ${response.statusCode}');

      if (response.statusCode != 200) {
        debugPrint('[NewsService] $label - body: ${response.body}');
        return const [];
      }

      final decoded = json.decode(response.body);
      if (decoded is! Map<String, dynamic>) {
        debugPrint('[NewsService] $label - unexpected payload shape');
        return const [];
      }

      if (decoded['status'] != 'success') {
        debugPrint(
          '[NewsService] $label - API error: ${decoded['status']} / ${decoded['message']}',
        );
        return const [];
      }

      final results = (decoded['results'] as List?) ?? const [];
      debugPrint('[NewsService] $label - got ${results.length} items');

      _cache[url] = _CachedResponse(results, DateTime.now());
      return results;
    } catch (e, st) {
      debugPrint('[NewsService] $label - exception: $e');
      debugPrintStack(stackTrace: st);
      return const [];
    }
  }

  // Hide the API key when logging URLs.
  String _sanitize(String url) =>
      url.replaceAll(RegExp(r'apikey=[^&]+'), 'apikey=***');
}

class _CachedResponse {
  _CachedResponse(this.data, this.savedAt);
  final List<dynamic> data;
  final DateTime savedAt;
  bool get isExpired =>
      DateTime.now().difference(savedAt) > NewsService._cacheTtl;
}
