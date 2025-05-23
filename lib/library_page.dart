import 'package:flutter/material.dart';
import 'home_page.dart';
import 'book_reader.dart';
import 'signlanguage.dart';
import 'book_assets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'progress_calculate.dart';

class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key});

  @override
  _LibraryPageState createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  Map<String, String> _bookProgress = {};
  String _signLanguageProgress = '0%';
  int _watchedVideosCount = 0;
  int _totalVideos = 3300; // Should match TOTAL_VIDEOS in signlanguage.dart
  List<BookConfig> _allBooks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBooksAndProgress();
  }

  Future<void> _loadBooksAndProgress() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Fetch admin books
      final adminBooks = await fetchAdminBooks();
      // Combine hardcoded and admin books
      _allBooks = [...hardcodedBooks, ...adminBooks];

      final prefs = await SharedPreferences.getInstance();

      // Load progress for each book
      setState(() {
        _bookProgress = {};
        for (var book in _allBooks) {
          double progress = prefs.getDouble('${book.bookId}_progress') ?? 0.0;
          _bookProgress[book.bookId] = '${progress.toStringAsFixed(0)}%';
        }
      });

      // Load sign language progress for ESL category
      final eslProgress = await ProgressCalculator.getProgressForCategory('ESL');
      final watchedCount = prefs.getInt('watched_words_count') ?? 0;
      setState(() {
        _watchedVideosCount = watchedCount;
        _signLanguageProgress = '${eslProgress.toStringAsFixed(0)}%';
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading books or progress: $e');
      setState(() {
        _allBooks = hardcodedBooks; // Fallback to hardcoded books
        _isLoading = false;
      });
    }
  }

  Future<void> _updateOpenedLessons({
    required String id,
    required String title,
    required String description,
    required String image,
    required String progress,
    required String category,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<Map<String, dynamic>> openedLessons = [];

      // Load existing opened lessons
      String? lessonsJson = prefs.getString('opened_lessons');
      if (lessonsJson != null) {
        try {
          openedLessons = List<Map<String, dynamic>>.from(jsonDecode(lessonsJson));
        } catch (e) {
          print('Error decoding opened_lessons: $e');
          openedLessons = [];
        }
      }

      // Remove existing entry for this lesson (if any)
      openedLessons.removeWhere((lesson) => lesson['id'] == id);

      // Add new entry with current timestamp
      openedLessons.add({
        'id': id,
        'title': title,
        'description': description,
        'image': image,
        'progress': progress,
        'category': category,
        'opened_at': DateTime.now().toIso8601String(),
      });

      // Limit to 5 lessons (remove oldest if necessary)
      if (openedLessons.length > 5) {
        openedLessons.sort((a, b) => DateTime.parse(b['opened_at']).compareTo(DateTime.parse(a['opened_at'])));
        openedLessons = openedLessons.sublist(0, 5);
      }

      // Save updated list
      await prefs.setString('opened_lessons', jsonEncode(openedLessons));
    } catch (e) {
      print('Error updating opened lessons: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F1E5),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Library",
                style: TextStyle(
                  fontFamily: 'Rubik',
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF251504),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _allBooks.isEmpty
                        ? const Center(child: Text('No books available', style: TextStyle(fontSize: 18)))
                        : ListView(
                            children: [
                              // Display all books
                              ..._allBooks.map((book) => GestureDetector(
                                    onTap: () async {
                                      // Update opened lessons
                                      await _updateOpenedLessons(
                                        id: book.bookId,
                                        title: book.title,
                                        description: book.description,
                                        image: book.coverImage,
                                        progress: _bookProgress[book.bookId] ?? '0%',
                                        category: book.category,
                                      );
                                      // Navigate and reload progress
                                      await Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => PreloadApp(bookId: book.bookId)),
                                      );
                                      await _loadBooksAndProgress();
                                    },
                                    child: LessonCard(
                                      title: book.title,
                                      description: book.description,
                                      progress: _bookProgress[book.bookId] ?? '0%',
                                      image: book.coverImage,
                                      category: book.category,
                                    ),
                                  )),
                              const SizedBox(height: 20),
                              // Sign Language lesson (ESL)
                              GestureDetector(
                                onTap: () async {
                                  // Update ESL game progress based on watched videos
                                  final prefs = await SharedPreferences.getInstance();
                                  final watchedCount = prefs.getInt('watched_words_count') ?? 0;
                                  await prefs.setInt('ESL_count', watchedCount);

                                  // Update opened lessons
                                  await _updateOpenedLessons(
                                    id: 'signlanguage',
                                    title: 'ESL: Sign Language',
                                    description: '3,300 sign language videos available',
                                    image: 'assets/signlanguage.jpg',
                                    progress: _signLanguageProgress,
                                    category: 'ESL',
                                  );

                                  // Track session time (estimate 60 seconds per interaction)
                                  const sessionTime = 60.0;
                                  await ProgressCalculator.updateGameTime('ESL', sessionTime);

                                  // Navigate and reload progress
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const VideoListScreen()),
                                  );
                                  await _loadBooksAndProgress();
                                },
                                child: LessonCard(
                                  title: 'ESL: Sign Language',
                                  description: '3,300 sign language videos available',
                                  progress: _signLanguageProgress,
                                  image: 'assets/signlanguage.jpg',
                                  category: 'ESL',
                                  extraInfo: 'Watched $_watchedVideosCount/$_totalVideos ($_signLanguageProgress)',
                                ),
                              ),
                            ],
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LessonCard extends StatelessWidget {
  final String title;
  final String description;
  final String progress;
  final String image;
  final String category;
  final String? extraInfo;

  const LessonCard({
    super.key,
    required this.title,
    required this.description,
    required this.progress,
    required this.image,
    required this.category,
    this.extraInfo,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: image.startsWith('assets/')
                  ? Image.asset(
                      image,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    )
                  : Image.network(
                      image,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.broken_image,
                        size: 60,
                        color: Colors.grey,
                      ),
                    ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'Rubik',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF251504),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(
                      fontFamily: 'Rubik',
                      fontSize: 14,
                      color: Color(0xFF87837B),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Category: $category',
                    style: const TextStyle(
                      fontFamily: 'Rubik',
                      fontSize: 12,
                      color: Color(0xFFDB4827),
                    ),
                  ),
                  if (extraInfo != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      extraInfo!,
                      style: const TextStyle(
                        fontFamily: 'Rubik',
                        fontSize: 12,
                        color: Color(0xFFDB4827),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              progress,
              style: const TextStyle(
                fontFamily: 'Rubik',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFFF34F27),
              ),
            ),
          ],
        ),
      ),
    );
  }
}