import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'book_assets.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

class ProgressCalculator {
  // Shared categories for books and games
  static const List<String> categories = ['science', 'math', 'language', 'ESL'];

  // Backend API base URL
  static const String _baseUrl = 'https://backend-lesu72cxy-g4s-projects-7b5d827c.vercel.app';

  // Mock daily data for fallback
  static final _mockDailyReport = {
    'science': {'time': 127.309, 'progress': 33.33},
    'math': {'time': 0.0, 'progress': 0.0},
    'language': {'time': 26.048, 'progress': 10.0},
    'ESL': {'time': 0.0, 'progress': 0.0},
  };

  // Secure storage for JWT token
  static const _storage = FlutterSecureStorage();

  // List to hold all books
  static List<BookConfig> _books = [];

  // Initialize books (call once at app start or when needed)
  static Future<void> initializeBooks() async {
    try {
      final adminBooks = await fetchAdminBooks();
      _books = [...hardcodedBooks, ...adminBooks];
      print('ProgressCalculator: Initialized ${_books.length} books');
    } catch (e) {
      print('ProgressCalculator: Error fetching books: $e');
      _books = hardcodedBooks; // Fallback to hardcoded books
      print('ProgressCalculator: Fell back to ${hardcodedBooks.length} hardcoded books');
    }
  }

  // Get date as YYYY-MM-DD
  static String _getDateString(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  // Get current date as YYYY-MM-DD
  static String _getCurrentDate() {
    return _getDateString(DateTime.now());
  }

  // Get JWT token from secure storage
  static Future<String?> _getToken() async {
    final token = await _storage.read(key: 'jwt_token');
    if (token == null) {
      print('ProgressCalculator: No JWT token found in FlutterSecureStorage. Please log in again.');
    } else {
      print('ProgressCalculator: Retrieved JWT token from FlutterSecureStorage');
    }
    return token;
  }

  // Save combined progress locally
  static Future<void> _saveCombinedProgressLocally(String category, double progress, double screenTime, String date) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '${category}_combined_progress_$date';
    await prefs.setString(key, jsonEncode({
      'progress': progress,
      'screenTime': screenTime,
    }));
    print('ProgressCalculator: Saved combined progress locally for $category on $date: $progress%, $screenTime seconds');
  }

  // Get combined progress locally
  static Future<Map<String, double>> _getCombinedProgressLocally(String category, String date) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '${category}_combined_progress_$date';
    final data = prefs.getString(key);
    if (data == null) {
      print('ProgressCalculator: No local combined progress for $category on $date');
      return {'progress': 0.0, 'screenTime': 0.0};
    }
    final decoded = jsonDecode(data) as Map<String, dynamic>;
    print('ProgressCalculator: Retrieved local combined progress for $category on $date: ${decoded['progress']}%, ${decoded['screenTime']} seconds');
    return {
      'progress': decoded['progress']?.toDouble() ?? 0.0,
      'screenTime': decoded['screenTime']?.toDouble() ?? 0.0,
    };
  }

  // Calculate game progress for a category
  static Future<double> getGameProgress(String category) async {
    if (!categories.contains(category)) {
      print('ProgressCalculator: Invalid category: $category');
      return 0.0;
    }

    final prefs = await SharedPreferences.getInstance();
    double totalProgress = 0.0;
    int gameCount = 0;

    if (category == 'ESL') {
      final watchedCount = prefs.getInt('watched_words_count') ?? 0;
      const totalVideos = 3300;
      final progress = (watchedCount / totalVideos) * 100.0;
      totalProgress += progress.clamp(0.0, 100.0);
      gameCount++;
      print('ProgressCalculator: ESL game (signlanguage) watched: $watchedCount/$totalVideos, progress: ${totalProgress}%');
    } else {
      final pressCount = prefs.getInt('${category}_count') ?? 0;
      final progress = (pressCount / 10.0) * 100.0;
      totalProgress += progress.clamp(0.0, 100.0);
      gameCount++;
      print('ProgressCalculator: $category game press count: $pressCount, progress: ${totalProgress}%');
    }

    final averageProgress = gameCount > 0 ? (totalProgress / gameCount) : 0.0;
    final cappedProgress = averageProgress.clamp(0.0, 100.0);
    print('ProgressCalculator: $category game progress: $cappedProgress% ($gameCount games)');
    return cappedProgress;
  }

  // Calculate book progress for a category
  static Future<double> getBookProgress(String category) async {
    if (!categories.contains(category)) {
      print('ProgressCalculator: Invalid category: $category');
      return 0.0;
    }

    if (_books.isEmpty) {
      await initializeBooks();
    }

    final token = await _getToken();
    final prefs = await SharedPreferences.getInstance();
    final booksInCategory = _books.where((book) => book.category == category).toList();
    if (booksInCategory.isEmpty) {
      print('ProgressCalculator: No books in $category');
      return 0.0;
    }

    double totalProgress = 0.0;
    int bookCount = 0;

    if (token == null) {
      // Fallback to local storage
      print('ProgressCalculator: Using local book progress due to missing token');
      for (final book in booksInCategory) {
        final progress = prefs.getDouble('${book.bookId}_progress') ?? 0.0;
        totalProgress += progress.clamp(0.0, 100.0);
        bookCount++;
        print('ProgressCalculator: ${book.bookId} local progress: $progress%');
      }
    } else {
      try {
        final response = await http.get(
          Uri.parse('$_baseUrl/book-progress'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        );

        if (response.statusCode != 200) {
          print('ProgressCalculator: Failed to fetch book progress: ${response.statusCode} ${response.body}');
          // Fallback to local storage
          for (final book in booksInCategory) {
            final progress = prefs.getDouble('${book.bookId}_progress') ?? 0.0;
            totalProgress += progress.clamp(0.0, 100.0);
            bookCount++;
            print('ProgressCalculator: ${book.bookId} local progress (backend failure): $progress%');
          }
        } else {
          final data = jsonDecode(response.body);
          final bookProgress = data['bookProgress'] ?? {};

          for (final book in booksInCategory) {
            final progress = (bookProgress[book.bookId]?['progress'] ?? 0.0) as double;
            totalProgress += progress.clamp(0.0, 100.0);
            bookCount++;
            // Save to local storage for offline use
            await prefs.setDouble('${book.bookId}_progress', progress);
            print('ProgressCalculator: ${book.bookId} progress: $progress%');
          }
        }
      } catch (e) {
        print('ProgressCalculator: Error fetching book progress: $e');
        // Fallback to local storage
        for (final book in booksInCategory) {
          final progress = prefs.getDouble('${book.bookId}_progress') ?? 0.0;
          totalProgress += progress.clamp(0.0, 100.0);
          bookCount++;
          print('ProgressCalculator: ${book.bookId} local progress (error): $progress%');
        }
      }
    }

    final averageProgress = bookCount > 0 ? (totalProgress / bookCount) : 0.0;
    final cappedProgress = averageProgress.clamp(0.0, 100.0);
    print('ProgressCalculator: $category book progress: $cappedProgress% ($bookCount books)');
    return cappedProgress;
  }

  // Combined progress (average of book and game progress)
  static Future<double> getProgressForCategory(String category) async {
    if (!categories.contains(category)) {
      print('ProgressCalculator: Invalid category: $category');
      return 0.0;
    }

    final bookProgress = await getBookProgress(category);
    final gameProgress = await getGameProgress(category);
    final totalTime = await getTotalTime(category);
    final currentDate = _getCurrentDate();

    final combinedProgress = (bookProgress + gameProgress) / 2.0;
    final cappedProgress = combinedProgress.clamp(0.0, 100.0);
    print('ProgressCalculator: $category combined progress: $cappedProgress% (book: $bookProgress%, game: $gameProgress%)');

    // Save combined progress locally
    await _saveCombinedProgressLocally(category, cappedProgress, totalTime, currentDate);

    // Save to backend
    final token = await _getToken();
    if (token != null) {
      try {
        final response = await http.post(
          Uri.parse('$_baseUrl/update-category-progress'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'category': category,
            'progress': cappedProgress,
            'screenTime': totalTime,
          }),
        );

        if (response.statusCode != 200) {
          print('ProgressCalculator: Failed to save category progress: ${response.statusCode} ${response.body}');
        } else {
          print('ProgressCalculator: Successfully saved category progress for $category');
        }
      } catch (e) {
        print('ProgressCalculator: Error saving category progress: $e');
      }
    } else {
      print('ProgressCalculator: No JWT token found for saving category progress');
    }

    return cappedProgress;
  }

  // Get total game time (local fallback)
  static Future<double> getGameTime(String category) async {
    if (!categories.contains(category)) {
      print('ProgressCalculator: Invalid category: $category');
      return 0.0;
    }

    final prefs = await SharedPreferences.getInstance();
    final totalTime = prefs.getDouble('${category}_game_time') ?? 0.0;
    print('ProgressCalculator: $category game total time: $totalTime seconds');
    return totalTime;
  }

  // Get daily game time (local fallback)
  static Future<double> getDailyGameTime(String category, {DateTime? date}) async {
    if (!categories.contains(category)) {
      print('ProgressCalculator: Invalid category: $category');
      return 0.0;
    }

    final prefs = await SharedPreferences.getInstance();
    final dateString = date != null ? _getDateString(date) : _getCurrentDate();
    final dailyTime = prefs.getDouble('${category}_daily_game_time_$dateString') ?? 0.0;
    print('ProgressCalculator: $category daily game time ($dateString): $dailyTime seconds');
    return dailyTime;
  }

  // Update game time (local and backend)
  static Future<void> updateGameTime(String category, double sessionTime) async {
    if (!categories.contains(category)) {
      print('ProgressCalculator: Invalid category for time update: $category');
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final currentDate = _getCurrentDate();

    // Update local total game time
    final currentTotalTime = prefs.getDouble('${category}_game_time') ?? 0.0;
    final newTotalTime = currentTotalTime + sessionTime;
    await prefs.setDouble('${category}_game_time', newTotalTime);

    // Update local daily game time
    final currentDailyTime = prefs.getDouble('${category}_daily_game_time_$currentDate') ?? 0.0;
    final newDailyTime = currentDailyTime + sessionTime;
    await prefs.setDouble('${category}_daily_game_time_$currentDate', newDailyTime);

    print('ProgressCalculator: Updated $category game time - Total: $newTotalTime seconds, Daily ($currentDate): $newDailyTime seconds');

    // Update combined progress
    final progress = await getProgressForCategory(category);

    // Save to backend
    final token = await _getToken();
    if (token != null) {
      try {
        final response = await http.post(
          Uri.parse('$_baseUrl/update-category-progress'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'category': category,
            'progress': progress,
            'screenTime': newDailyTime,
          }),
        );

        if (response.statusCode != 200) {
          print('ProgressCalculator: Failed to save game time progress: ${response.statusCode} ${response.body}');
        } else {
          print('ProgressCalculator: Successfully saved game time progress for $category');
        }
      } catch (e) {
        print('ProgressCalculator: Error saving game time progress: $e');
      }
    } else {
      print('ProgressCalculator: No JWT token found for saving game time progress');
      // Save locally as fallback
      await _saveCombinedProgressLocally(category, progress, newDailyTime, currentDate);
    }
  }

  // Get total book time (local)
  static Future<double> getBookTime(String category) async {
    if (!categories.contains(category)) {
      print('ProgressCalculator: Invalid category: $category');
      return 0.0;
    }

    if (_books.isEmpty) {
      await initializeBooks();
    }

    final booksInCategory = _books.where((book) => book.category == category).toList();
    if (booksInCategory.isEmpty) {
      print('ProgressCalculator: No books in $category');
      return 0.0;
    }

    final prefs = await SharedPreferences.getInstance();
    double totalTime = 0.0;
    for (final book in booksInCategory) {
      final sessionTime = prefs.getDouble('${book.bookId}_session_time') ?? 0.0;
      totalTime += sessionTime;
      print('ProgressCalculator: ${book.bookId} session time: $sessionTime seconds');
    }

    print('ProgressCalculator: $category book total time: $totalTime seconds');
    return totalTime;
  }

  // Get daily book time (local fallback)
  static Future<double> getDailyBookTime(String category, {DateTime? date}) async {
    if (!categories.contains(category)) {
      print('ProgressCalculator: Invalid category: $category');
      return 0.0;
    }

    final prefs = await SharedPreferences.getInstance();
    final dateString = date != null ? _getDateString(date) : _getCurrentDate();
    final dailyTime = prefs.getDouble('${category}_daily_book_time_$dateString') ?? 0.0;
    print('ProgressCalculator: $category daily book time ($dateString): $dailyTime seconds');
    return dailyTime;
  }

  // Update book time (local and backend)
  static Future<void> updateBookTime(String bookId, double sessionTime) async {
    if (_books.isEmpty) {
      await initializeBooks();
    }

    final book = _books.firstWhere(
      (b) => b.bookId == bookId,
      orElse: () {
        print('ProgressCalculator: Book $bookId not found');
        return BookConfig(
          bookId: bookId,
          title: '',
          description: '',
          coverImage: '',
          pageImageUrls: [],
          category: '',
          pageTexts: {},
          audioUrls: [],
          backgroundImageUrl: '',
        );
      },
    );

    if (book.category.isEmpty || !categories.contains(book.category)) {
      print('ProgressCalculator: Invalid category for $bookId: ${book.category}');
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final currentDate = _getCurrentDate();

    // Update local book session time
    final currentSessionTime = prefs.getDouble('${bookId}_session_time') ?? 0.0;
    final newSessionTime = currentSessionTime + sessionTime;
    await prefs.setDouble('${bookId}_session_time', newSessionTime);

    // Update local category daily book time
    final currentDailyTime = prefs.getDouble('${book.category}_daily_book_time_$currentDate') ?? 0.0;
    final newDailyTime = currentDailyTime + sessionTime;
    await prefs.setDouble('${book.category}_daily_book_time_$currentDate', newDailyTime);

    print('ProgressCalculator: Updated $bookId time - Book total: $newSessionTime seconds, Category ${book.category} daily book ($currentDate): $newDailyTime seconds');

    // Update combined progress
    final progress = await getProgressForCategory(book.category);

    // Save to backend
    final token = await _getToken();
    if (token != null) {
      try {
        final response = await http.post(
          Uri.parse('$_baseUrl/update-category-progress'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'category': book.category,
            'progress': progress,
            'screenTime': newDailyTime,
          }),
        );

        if (response.statusCode != 200) {
          print('ProgressCalculator: Failed to save book time progress: ${response.statusCode} ${response.body}');
        } else {
          print('ProgressCalculator: Successfully saved book time progress for ${book.category}');
        }
      } catch (e) {
        print('ProgressCalculator: Error saving book time progress: $e');
      }
    } else {
      print('ProgressCalculator: No JWT token found for saving book time progress');
      // Save locally as fallback
      await _saveCombinedProgressLocally(book.category, progress, newDailyTime, currentDate);
    }
  }

  // Get combined time (book + game)
  static Future<double> getTotalTime(String category) async {
    final bookTime = await getBookTime(category);
    final gameTime = await getGameTime(category);
    final totalTime = bookTime + gameTime;
    print('ProgressCalculator: $category total time: $totalTime seconds (book: $bookTime, game: $gameTime)');
    return totalTime;
  }

  // Get combined daily time
  static Future<double> getDailyTime(String category, {DateTime? date}) async {
    final bookTime = await getDailyBookTime(category, date: date);
    final gameTime = await getDailyGameTime(category, date: date);
    final totalTime = bookTime + gameTime;
    final dateString = date != null ? _getDateString(date) : _getCurrentDate();
    print('ProgressCalculator: $category daily time ($dateString): $totalTime seconds (book: $bookTime, game: $gameTime)');
    return totalTime;
  }

  // Get all progress
  static Future<Map<String, double>> getAllProgress() async {
    final Map<String, double> progressMap = {};
    for (final category in categories) {
      progressMap[category] = await getProgressForCategory(category);
    }
    return progressMap;
  }

  // Get all total times
  static Future<Map<String, double>> getAllTimes() async {
    final Map<String, double> timeMap = {};
    for (final category in categories) {
      timeMap[category] = await getTotalTime(category);
    }
    return timeMap;
  }

  // Get report from backend or local
  static Future<Map<String, Map<String, double>>> _fetchReport(String timeframe, {DateTime? date}) async {
    final token = await _getToken();
    final currentDate = date != null ? _getDateString(date) : _getCurrentDate();
    final report = <String, Map<String, double>>{};

    if (token == null) {
      print('ProgressCalculator: No JWT token found, using local data for $timeframe report');
      for (final category in categories) {
        if (timeframe == 'daily') {
          final localData = await _getCombinedProgressLocally(category, currentDate);
          report[category] = {
            'time': localData['screenTime'] ?? 0.0,
            'progress': localData['progress'] ?? 0.0,
          };
        } else {
          // For weekly, monthly, yearly, use mock data as local aggregation is complex
          report[category] = _mockDailyReport[category] ?? {'time': 0.0, 'progress': 0.0};
        }
      }
      return report;
    }

    try {
      final query = date != null ? {'timeframe': timeframe, 'date': currentDate} : {'timeframe': timeframe};
      final uri = Uri.parse('$_baseUrl/category-progress').replace(queryParameters: query);
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode != 200) {
        print('ProgressCalculator: Failed to fetch $timeframe report: ${response.statusCode} ${response.body}');
        // Fallback to local data
        for (final category in categories) {
          if (timeframe == 'daily') {
            final localData = await _getCombinedProgressLocally(category, currentDate);
            report[category] = {
              'time': localData['screenTime'] ?? 0.0,
              'progress': localData['progress'] ?? 0.0,
            };
          } else {
            report[category] = _mockDailyReport[category] ?? {'time': 0.0, 'progress': 0.0};
          }
        }
        return report;
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      for (final category in categories) {
        report[category] = {
          'time': (data[category]?['screenTime'] ?? 0.0).toDouble(),
          'progress': (data[category]?['progress'] ?? 0.0).toDouble(),
        };
        // Save daily report locally
        if (timeframe == 'daily') {
          await _saveCombinedProgressLocally(category, report[category]!['progress']!, report[category]!['time']!, currentDate);
        }
      }
      print('ProgressCalculator: Successfully fetched $timeframe report from backend');
      return report;
    } catch (e) {
      print('ProgressCalculator: Error fetching $timeframe report: $e');
      // Fallback to local data
      for (final category in categories) {
        if (timeframe == 'daily') {
          final localData = await _getCombinedProgressLocally(category, currentDate);
          report[category] = {
            'time': localData['screenTime'] ?? 0.0,
            'progress': localData['progress'] ?? 0.0,
          };
        } else {
          report[category] = _mockDailyReport[category] ?? {'time': 0.0, 'progress': 0.0};
        }
      }
      return report;
    }
  }

  // Get daily report
  static Future<Map<String, Map<String, double>>> getDailyReport() async {
    final report = await _fetchReport('daily');
    final currentDate = _getCurrentDate();
    print('Daily Report for $currentDate:');
    for (final entry in report.entries) {
      final minutes = (entry.value['time']! / 60.0).toStringAsFixed(2);
      final progress = entry.value['progress']!.toStringAsFixed(2);
      print('- ${entry.key}: $minutes minutes, Progress: $progress%');
    }
    return report;
  }

  // Get weekly report (current week)
  static Future<Map<String, Map<String, double>>> getWeeklyReport() async {
    final report = await _fetchReport('weekly');
    print('Weekly Report:');
    for (final entry in report.entries) {
      final minutes = (entry.value['time']! / 60.0).toStringAsFixed(2);
      final progress = entry.value['progress']!.toStringAsFixed(2);
      print('- ${entry.key}: $minutes minutes, Progress: $progress%');
    }
    return report;
  }

  // Get monthly report (current month)
  static Future<Map<String, Map<String, double>>> getMonthlyReport() async {
    final report = await _fetchReport('monthly');
    print('Monthly Report:');
    for (final entry in report.entries) {
      final minutes = (entry.value['time']! / 60.0).toStringAsFixed(2);
      final progress = entry.value['progress']!.toStringAsFixed(2);
      print('- ${entry.key}: $minutes minutes, Progress: $progress%');
    }
    return report;
  }

  // Get yearly report (current year)
  static Future<Map<String, Map<String, double>>> getYearlyReport() async {
    final report = await _fetchReport('yearly');
    print('Yearly Report:');
    for (final entry in report.entries) {
      final minutes = (entry.value['time']! / 60.0).toStringAsFixed(2);
      final progress = entry.value['progress']!.toStringAsFixed(2);
      print('- ${entry.key}: $minutes minutes, Progress: $progress%');
    }
    return report;
  }

  // Total progress across all categories
  static Future<double> getTotalProgress() async {
    final allProgress = await getAllProgress();
    if (allProgress.isEmpty) {
      print('ProgressCalculator: No progress data');
      return 0.0;
    }

    double total = 0.0;
    int count = 0;
    for (final progress in allProgress.values) {
      total += progress;
      count++;
    }

    final averageProgress = count > 0 ? (total / count) : 0.0;
    final cappedProgress = averageProgress.clamp(0.0, 100.0);
    print('ProgressCalculator: Total progress: $cappedProgress% ($count categories)');
    return cappedProgress;
  }

  // Reset category progress and time
  static Future<void> resetCategoryProgress(String category) async {
    if (!categories.contains(category)) {
      print('ProgressCalculator: Invalid category for reset: $category');
      return;
    }

    if (_books.isEmpty) {
      await initializeBooks();
    }

    final prefs = await SharedPreferences.getInstance();
    final currentDate = _getCurrentDate();

    // Reset local data
    await prefs.remove('${category}_count');
    await prefs.remove('${category}_game_time');
    await prefs.remove('${category}_start_time');
    await prefs.remove('${category}_daily_game_time_$currentDate');

    final booksInCategory = _books.where((book) => book.category == category).toList();
    for (final book in booksInCategory) {
      await prefs.remove('${book.bookId}_session_time');
      await prefs.remove('${book.bookId}_progress');
    }
    await prefs.remove('${category}_daily_book_time_$currentDate');
    if (category == 'ESL') {
      await prefs.remove('watched_words_count');
    }
    await prefs.remove('${category}_combined_progress_$currentDate');

    print('ProgressCalculator: Reset local progress and time for $category');

    // Reset backend data
    final token = await _getToken();
    if (token != null) {
      try {
        final response = await http.post(
          Uri.parse('$_baseUrl/update-category-progress'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'category': category,
            'progress': 0.0,
            'screenTime': 0.0,
          }),
        );

        if (response.statusCode != 200) {
          print('ProgressCalculator: Failed to reset category progress: ${response.statusCode} ${response.body}');
        } else {
          print('ProgressCalculator: Successfully reset category progress for $category');
        }
      } catch (e) {
        print('ProgressCalculator: Error resetting category progress: $e');
      }
    } else {
      print('ProgressCalculator: No JWT token found for resetting category progress');
    }
  }

  // Reset all progress and time
  static Future<void> resetAllProgress() async {
    if (_books.isEmpty) {
      await initializeBooks();
    }

    final prefs = await SharedPreferences.getInstance();
    final currentDate = _getCurrentDate();

    // Reset local data
    for (final category in categories) {
      await prefs.remove('${category}_count');
      await prefs.remove('${category}_game_time');
      await prefs.remove('${category}_start_time');
      await prefs.remove('${category}_daily_game_time_$currentDate');
      await prefs.remove('${category}_daily_book_time_$currentDate');
      await prefs.remove('${category}_combined_progress_$currentDate');
    }

    for (final book in _books) {
      await prefs.remove('${book.bookId}_session_time');
      await prefs.remove('${book.bookId}_progress');
    }
    await prefs.remove('watched_words_count');

    print('ProgressCalculator: Reset all local progress and time');

    // Reset backend data
    final token = await _getToken();
    if (token != null) {
      try {
        for (final category in categories) {
          final response = await http.post(
            Uri.parse('$_baseUrl/update-category-progress'),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'category': category,
              'progress': 0.0,
              'screenTime': 0.0,
            }),
          );

          if (response.statusCode != 200) {
            print('ProgressCalculator: Failed to reset progress for $category: ${response.statusCode} ${response.body}');
          } else {
            print('ProgressCalculator: Successfully reset progress for $category');
          }
        }
      } catch (e) {
        print('ProgressCalculator: Error resetting all progress: $e');
      }
    } else {
      print('ProgressCalculator: No JWT token found for resetting all progress');
    }
  }
}