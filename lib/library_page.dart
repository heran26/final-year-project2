import 'package:flutter/material.dart';
import 'home_page.dart';
import 'book_reader.dart';
import 'signlanguage.dart';
import 'book_assets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

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

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Load progress for each book
      setState(() {
        _bookProgress = {};
        for (var book in books) {
          double progress = prefs.getDouble('${book.bookId}_progress') ?? 0.0;
          _bookProgress[book.bookId] = '${progress.toStringAsFixed(0)}%';
        }
      });

      // Load sign language progress
      final watchedCount = prefs.getInt('watched_words_count') ?? 0;
      setState(() {
        _watchedVideosCount = watchedCount;
        _signLanguageProgress = '${(watchedCount / _totalVideos * 100).toStringAsFixed(0)}%';
      });
    } catch (e) {
      print('Error loading progress: $e');
    }
  }

  Future<void> _updateOpenedLessons({
    required String id,
    required String title,
    required String description,
    required String image,
    required String progress,
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
                child: ListView(
                  children: [
                    // Display all books
                    ...books.map((book) => GestureDetector(
                          onTap: () async {
                            // Update opened lessons
                            await _updateOpenedLessons(
                              id: book.bookId,
                              title: book.title,
                              description: book.description,
                              image: book.coverImage,
                              progress: _bookProgress[book.bookId] ?? '0%',
                            );
                            // Navigate and reload progress
                            await Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => PreloadApp(bookId: book.bookId)),
                            );
                            await _loadProgress();
                          },
                          child: LessonCard(
                            title: book.title,
                            description: book.description,
                            progress: _bookProgress[book.bookId] ?? '0%',
                            image: book.coverImage,
                          ),
                        )),
                    const SizedBox(height: 20),
                    // Sign Language lesson
                    GestureDetector(
                      onTap: () async {
                        // Update opened lessons
                        await _updateOpenedLessons(
                          id: 'signlanguage',
                          title: 'Sign Language',
                          description: '3,300 sign language videos available',
                          image: 'assets/signlanguage.jpg',
                          progress: _signLanguageProgress,
                        );
                        // Navigate and reload progress
                        await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const VideoListScreen()),
                        );
                        await _loadProgress();
                      },
                      child: LessonCard(
                        title: "Sign Language",
                        description: "3,300 sign language videos available",
                        progress: _signLanguageProgress,
                        image: 'assets/signlanguage.jpg',
                        extraInfo: "Watched $_watchedVideosCount/$_totalVideos ($_signLanguageProgress)",
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
  final String? extraInfo;

  const LessonCard({
    super.key,
    required this.title,
    required this.description,
    required this.progress,
    required this.image,
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