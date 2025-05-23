import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'dart:math' show pi;
import 'book_reader.dart';
import 'signlanguage.dart';
import 'book_assets.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late ScrollController _scrollController;
  int _activeSlide = 0;
  bool _book1Opened = false;
  bool _signlanguageOpened = false;
  Map<String, String> _bookProgress = {};
  String _signlanguageProgress = '0%';
  late SharedPreferences _prefs;
  List<Map<String, dynamic>> _openedLessons = [];
  List<String> _selectedInterests = [];
  List<String> _learningPathOrder = [
    'ESL',
    'English',
    'Amharic',
    'Math',
    'Science',
  ];
  String? _userName;
  String? _userAvatar;
  bool _isLoadingUser = true;
  final storage = const FlutterSecureStorage();
  List<BookConfig> _books = []; // List to hold all books
  bool _isLoadingBooks = true;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_updateActiveSlide);
    _loadBooksAndProgress();
    _fetchUserData();
  }

  Future<void> _loadBooksAndProgress() async {
    try {
      // Fetch books (hardcoded and admin-created)
      final adminBooks = await fetchAdminBooks();
      final allBooks = [...hardcodedBooks, ...adminBooks];
      _prefs = await SharedPreferences.getInstance();

      setState(() {
        _books = allBooks;
        _isLoadingBooks = false;
      });

      await _loadProgress();
    } catch (e) {
      print('Error loading books: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load books: $e')),
      );
      setState(() {
        _books = hardcodedBooks; // Fallback to hardcoded books
        _isLoadingBooks = false;
      });
      await _loadProgress();
    }
  }

  Future<void> _fetchUserData() async {
    try {
      final token = await storage.read(key: 'jwt_token');
      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please log in')),
        );
        Navigator.pushReplacementNamed(context, '/login');
        return;
      }

      final url = Uri.parse('https://backend-lesu72cxy-g4s-projects-7b5d827c.vercel.app/user');
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _userName = data['name'];
          _userAvatar = data['avatar'];
          _isLoadingUser = false;
        });
      } else {
        final error = jsonDecode(response.body)['error'];
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $error')),
        );
        setState(() {
          _userName = 'User';
          _userAvatar = 'assets/avatar8.png';
          _isLoadingUser = false;
        });
      }
    } catch (e) {
      print('Error fetching user data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
      setState(() {
        _userName = 'User';
        _userAvatar = 'assets/avatar8.png';
        _isLoadingUser = false;
      });
    }
  }

  Future<void> _loadProgress() async {
    try {
      final token = await storage.read(key: 'jwt_token');
      Map<String, double> tempBookProgress = {};
      double signlanguageProgress = 0.0;

      // Initialize progress for all books
      for (var book in _books) {
        tempBookProgress[book.bookId] = _prefs.getDouble('${book.bookId}_progress')?.clamp(0.0, 100.0) ?? 0.0;
      }
      signlanguageProgress = _prefs.getDouble('signlanguage_progress')?.clamp(0.0, 100.0) ?? 0.0;

      // Fetch progress from backend
      if (token != null) {
        final url = Uri.parse('https://backend-lesu72cxy-g4s-projects-7b5d827c.vercel.app/book-progress');
        final response = await http.get(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final backendProgress = data['bookProgress'] ?? {};

          // Update progress for all books
          for (var book in _books) {
            if (backendProgress[book.bookId] != null) {
              final progress = (backendProgress[book.bookId]['progress']?.toDouble() ?? 0.0).clamp(0.0, 100.0);
              tempBookProgress[book.bookId] = progress;
              await _prefs.setDouble('${book.bookId}_progress', progress);
            }
          }

          // Update signlanguage progress
          if (backendProgress['signlanguage'] != null) {
            signlanguageProgress = (backendProgress['signlanguage']['progress']?.toDouble() ?? 0.0).clamp(0.0, 100.0);
            await _prefs.setDouble('signlanguage_progress', signlanguageProgress);
            await _prefs.setInt('watched_words_count', (signlanguageProgress / 100 * 3300).round());
          }
        } else {
          print('Failed to fetch book progress from backend: ${response.statusCode} ${response.body}');
        }
      } else {
        print('No JWT token found, using SharedPreferences for progress');
      }

      // Update state with final progress values
      setState(() {
        _book1Opened = _prefs.getBool('book1_opened') ?? false;
        _signlanguageOpened = _prefs.getBool('signlanguage_opened') ?? false;
        _bookProgress = {
          for (var book in _books) book.bookId: '${tempBookProgress[book.bookId]!.toStringAsFixed(0)}%'
        };
        _signlanguageProgress = '${signlanguageProgress.toStringAsFixed(0)}%';

        String? lessonsJson = _prefs.getString('opened_lessons');
        if (lessonsJson != null) {
          try {
            _openedLessons = List<Map<String, dynamic>>.from(jsonDecode(lessonsJson));
            _openedLessons.sort((a, b) => DateTime.parse(b['opened_at']).compareTo(DateTime.parse(a['opened_at'])));
          } catch (e) {
            print('Error decoding opened_lessons: $e');
            _openedLessons = [];
          }
        } else {
          _openedLessons = [];
        }
      });
    } catch (e) {
      print('Error loading progress: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load progress: $e')),
      );
      setState(() {
        _bookProgress = {
          for (var book in _books)
            book.bookId: '${(_prefs.getDouble('${book.bookId}_progress')?.clamp(0.0, 100.0) ?? 0.0).toStringAsFixed(0)}%'
        };
        _signlanguageProgress = '${(_prefs.getDouble('signlanguage_progress')?.clamp(0.0, 100.0) ?? 0.0).toStringAsFixed(0)}%';
      });
    }
  }

  Future<void> _saveSingleLessonProgress(String lessonId) async {
    try {
      final token = await storage.read(key: 'jwt_token');
      if (token == null) {
        print('No JWT token found, saving progress locally');
        return;
      }

      final url = Uri.parse('https://backend-lesu72cxy-g4s-projects-7b5d827c.vercel.app/update-book-progress');

      if (lessonId == 'signlanguage') {
        final progress = double.tryParse(_signlanguageProgress.replaceAll('%', ''))?.clamp(0.0, 100.0) ?? 0.0;
        await _prefs.setDouble('signlanguage_progress', progress);
        await _prefs.setInt('watched_words_count', (progress / 100 * 3300).round());

        final response = await http.post(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({
            'bookId': 'signlanguage',
            'progress': progress,
            'currentPage': (progress / 100 * 3300).round(),
          }),
        );

        if (response.statusCode == 200) {
          print('Successfully saved signlanguage progress to backend: $progress%');
        } else {
          print('Failed to save signlanguage progress to backend: ${response.statusCode} ${response.body}');
        }
      } else {
        final book = _books.firstWhere((b) => b.bookId == lessonId, orElse: () => throw Exception('Book not found'));
        final progress = double.tryParse(_bookProgress[lessonId]?.replaceAll('%', '') ?? '0')?.clamp(0.0, 100.0) ?? 0.0;
        await _prefs.setDouble('${lessonId}_progress', progress);

        final response = await http.post(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({
            'bookId': lessonId,
            'progress': progress,
            'currentPage': (progress / 100 * book.pageImageUrls.length).round().clamp(0, book.pageImageUrls.length - 1),
          }),
        );

        if (response.statusCode == 200) {
          print('Successfully saved $lessonId progress to backend: $progress%');
        } else {
          print('Failed to save $lessonId progress to backend: ${response.statusCode} ${response.body}');
        }
      }

      // Refresh progress after saving
      await _loadProgress();
    } catch (e) {
      print('Error saving progress for $lessonId: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save progress: $e')),
      );
    }
  }

  Future<void> _updateOpenedLessons({
    required String id,
    required String title,
    required String description,
    required String image,
  }) async {
    try {
      _openedLessons.removeWhere((lesson) => lesson['id'] == id);
      _openedLessons.add({
        'id': id,
        'title': title,
        'description': description,
        'image': image,
        'opened_at': DateTime.now().toIso8601String(),
      });

      if (_openedLessons.length > 5) {
        _openedLessons.sort((a, b) => DateTime.parse(b['opened_at']).compareTo(DateTime.parse(a['opened_at'])));
        _openedLessons = _openedLessons.sublist(0, 5);
      }

      await _prefs.setString('opened_lessons', jsonEncode(_openedLessons));

      // Update flags
      if (id == 'book1') {
        await _prefs.setBool('book1_opened', true);
        setState(() {
          _book1Opened = true;
        });
      } else if (id == 'signlanguage') {
        await _prefs.setBool('signlanguage_opened', true);
        setState(() {
          _signlanguageOpened = true;
        });
      } else {
        await _prefs.setBool('${id}_opened', true);
      }

      setState(() {
        _openedLessons.sort((a, b) => DateTime.parse(b['opened_at']).compareTo(DateTime.parse(a['opened_at'])));
      });
    } catch (e) {
      print('Error updating opened lessons: $e');
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _updateActiveSlide() {
    if (_scrollController.hasClients) {
      double offset = _scrollController.offset;
      int newActiveSlide = (offset / 135).round().clamp(0, 3);
      if (newActiveSlide != _activeSlide) {
        setState(() {
          _activeSlide = newActiveSlide;
        });
      }
    }
  }

  void _toggleInterest(String title) {
    setState(() {
      if (_selectedInterests.contains(title)) {
        _selectedInterests.remove(title);
      } else if (_selectedInterests.length < 5) {
        _selectedInterests.add(title);
      }
    });
  }

  void _generateLearningPath() {
    const priorityOrder = [
      'ESL',
      'English',
      'Amharic',
      'Math',
      'Science',
      'Nature',
      'Cooking',
      'Adventure'
    ];
    List<String> newOrder = [];
    for (String interest in priorityOrder) {
      if (_selectedInterests.contains(interest)) {
        newOrder.add(interest);
      }
    }
    setState(() {
      _learningPathOrder = newOrder.length >= 5 ? newOrder : ['ESL', 'English', 'Amharic', 'Math', 'Science'];
    });
  }

  Future<bool> _onWillPop() async {
    bool? shouldSave = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Save Progress?'),
        content: const Text('Do you want to save your progress before leaving?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Yes'),
          ),
        ],
      ),
    );

    if (shouldSave == true) {
      for (var book in _books) {
        await _saveSingleLessonProgress(book.bookId);
      }
      await _saveSingleLessonProgress('signlanguage');
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingBooks || _isLoadingUser) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final book1Config = _books.firstWhere((book) => book.bookId == 'book1', orElse: () => throw Exception('Book1 not found'));

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F1E5),
        body: SafeArea(
          child: Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 20, left: 24, right: 24),
                      child: SizedBox(
                        height: 240,
                        child: Stack(
                          children: [
                            Positioned(
                              left: 250,
                              top: 0,
                              child: Image.asset(
                                'assets/Vector2.png',
                                width: 23.31,
                                height: 22.71,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              left: 1,
                              top: 10,
                              child: Image.asset(
                                'assets/Vector3.png',
                                width: 280.31,
                                height: 210.71,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Text(
                                          "Hi",
                                          style: TextStyle(
                                            fontFamily: 'Rubik',
                                            fontSize: 20,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF251504),
                                            height: 1.625,
                                          ),
                                        ),
                                        Text(
                                          " ${_userName ?? 'User'}!",
                                          style: const TextStyle(
                                            fontFamily: 'Rubik',
                                            fontSize: 20,
                                            fontWeight: FontWeight.w900,
                                            color: Color(0xFFDB4827),
                                            height: 1.625,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    const Text(
                                      "Let's learn something new today!",
                                      style: TextStyle(
                                        fontFamily: 'Rubik',
                                        fontSize: 13,
                                        fontWeight: FontWeight.w400,
                                        color: Color.fromARGB(255, 17, 17, 17),
                                        height: 1.3846,
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  width: 65,
                                  height: 63,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFF8BE0),
                                    border: Border.all(color: Colors.black, width: 5),
                                    borderRadius: BorderRadius.circular(100),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Color(0xFFEEEEEE),
                                        offset: Offset(0, 4),
                                        blurRadius: 4,
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(100),
                                    child: _userAvatar == null || _userAvatar!.isEmpty
                                        ? Image.asset(
                                            'assets/avatar8.png',
                                            fit: BoxFit.cover,
                                          )
                                        : Image.asset(
                                            _userAvatar!,
                                            width: 65,
                                            height: 63,
                                            fit: BoxFit.cover,
                                          ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 7),
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 11),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Choose interests (${_selectedInterests.length}/5)",
                                        style: const TextStyle(
                                          fontFamily: 'Rubik',
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF251504),
                                        ),
                                      ),
                                      const Text(
                                        "View all",
                                        style: TextStyle(
                                          fontFamily: 'Rubik',
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
                                          color: Color(0xFFDB4827),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                  SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    controller: _scrollController,
                                    child: Row(
                                      children: [
                                        InterestCard(
                                          title: "Nature",
                                          color: const Color(0xFFE6FFA2),
                                          borderColor: const Color.fromARGB(255, 67, 93, 0),
                                          image: 'assets/image3.png',
                                          isSelected: _selectedInterests.contains("Nature"),
                                          onTap: () => _toggleInterest("Nature"),
                                        ),
                                        const SizedBox(width: 10),
                                        InterestCard(
                                          title: "English",
                                          color: const Color(0xFFFCE2B9),
                                          borderColor: const Color.fromARGB(255, 64, 40, 1),
                                          image: 'assets/image.png',
                                          isSelected: _selectedInterests.contains("English"),
                                          onTap: () => _toggleInterest("English"),
                                        ),
                                        const SizedBox(width: 10),
                                        InterestCard(
                                          title: "Science",
                                          color: const Color(0xFFCBECFF),
                                          borderColor: const Color.fromARGB(255, 0, 39, 63),
                                          image: 'assets/science1.png',
                                          isSelected: _selectedInterests.contains("Science"),
                                          onTap: () => _toggleInterest("Science"),
                                        ),
                                        const SizedBox(width: 10),
                                        InterestCard(
                                          title: "Amharic",
                                          color: const Color.fromARGB(255, 248, 172, 244),
                                          borderColor: const Color.fromARGB(222, 83, 0, 81),
                                          image: 'assets/cover1.png',
                                          isSelected: _selectedInterests.contains("Amharic"),
                                          onTap: () => _toggleInterest("Amharic"),
                                        ),
                                        const SizedBox(width: 10),
                                        InterestCard(
                                          title: "ESL",
                                          color: const Color.fromARGB(255, 166, 248, 232),
                                          borderColor: const Color.fromARGB(255, 0, 55, 53),

                                          image: 'assets/signlanguage.jpg',
                                          isSelected: _selectedInterests.contains("ESL"),
                                          onTap: () => _toggleInterest("ESL"),
                                        ),
                                        const SizedBox(width: 10),
                                        InterestCard(
                                          title: "Math",
                                          color: const Color.fromARGB(255, 165, 247, 151),
                                          borderColor: const Color.fromARGB(255, 1, 86, 5),
                                          image: 'assets/math.gif',
                                          isSelected: _selectedInterests.contains("Math"),
                                          onTap: () => _toggleInterest("Math"),
                                        ),
                                        const SizedBox(width: 10),
                                        InterestCard(
                                          title: "Cooking",
                                          color: const Color.fromARGB(255, 245, 175, 175),
                                          borderColor: const Color.fromARGB(255, 164, 1, 39),
                                          image: 'assets/cooking.jpg',
                                          isSelected: _selectedInterests.contains("Cooking"),
                                          onTap: () => _toggleInterest("Cooking"),
                                        ),
                                        const SizedBox(width: 10),
                                        InterestCard(
                                          title: "Adventure",
                                          color: const Color.fromARGB(255, 255, 255, 162),
                                          borderColor: const Color.fromARGB(255, 103, 99, 0),
                                          image: 'assets/adventure.jpg',
                                          isSelected: _selectedInterests.contains("Adventure"),
                                          onTap: () => _toggleInterest("Adventure"),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            Center(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Dot(color: _activeSlide == 0 ? const Color(0xFF251504) : const Color(0xFFA9A391)),
                                  const SizedBox(width: 12),
                                  Dot(color: _activeSlide == 1 ? const Color(0xFF251504) : const Color(0xFFA9A391)),
                                  const SizedBox(width: 12),
                                  Dot(color: _activeSlide == 2 ? const Color(0xFF251504) : const Color(0xFFA9A391)),
                                  const SizedBox(width: 12),
                                  Dot(color: _activeSlide == 3 ? const Color(0xFF251504) : const Color(0xFFA9A391)),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 11),
                                child: GestureDetector(
                                  onTap: _selectedInterests.length == 5 ? _generateLearningPath : null,
                                  child: Container(
                                    width: 150,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      gradient: _selectedInterests.length == 5
                                          ? const LinearGradient(
                                              colors: [
                                                Color(0xFFFFC045),
                                                Color(0xFFF3561A),
                                              ],
                                            )
                                          : null,
                                      color: _selectedInterests.length < 5 ? const Color(0xFF87837B) : null,
                                      borderRadius: BorderRadius.circular(25),
                                      border: Border.all(color: const Color.fromARGB(255, 73, 11, 2), width: 2),
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Color(0x44B7AF9A),
                                          offset: Offset(0, 10),
                                          blurRadius: 16.9,
                                        ),
                                      ],
                                    ),
                                    child: Center(
                                      child: Text(
                                        'Generate',
                                        style: TextStyle(
                                          fontFamily: 'Rubik',
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                          color: _selectedInterests.length == 5 ? Colors.white : Colors.white70,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Padding(
                              padding: const EdgeInsets.only(left: 14),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Padding(
                                        padding: EdgeInsets.only(left: 16),
                                        child: Text(
                                          "Learning path",
                                          style: TextStyle(
                                            fontFamily: 'Rubik',
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF251504),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 122),
                                      Transform.rotate(
                                        angle: 55.19 * 3.14159 / 180,
                                        child: Container(
                                          width: 3.57,
                                          height: 7.29,
                                          color: const Color(0x33FFFFFF),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 5),
                                  Container(
                                    width: 382.17,
                                    height: 352.31,
                                    child: Stack(
                                      children: [
                                        Positioned(
                                          left: 62.76,
                                          top: 50.01,
                                          child: Image.asset(
                                            'assets/Vector.png',
                                            width: 230.31,
                                            height: 220.71,
                                          ),
                                        ),
                                        ..._learningPathOrder.asMap().entries.map((entry) {
                                          int idx = entry.key;
                                          String label = entry.value;
                                          double top = 20.94;
                                          double left = 2.63;
                                          switch (idx) {
                                            case 0:
                                              top = 20.94;
                                              left = 2.63;
                                              break;
                                            case 1:
                                              top = 64.24;
                                              left = 95.65;
                                              break;
                                            case 2:
                                              top = 169.50;
                                              left = 104.23;
                                              break;
                                            case 3:
                                              top = 208.88;
                                              left: 189.31;
                                              break;
                                            case 4:
                                              top = 238.88;
                                              left = 279.31;
                                              break;
                                            default:
                                              top = 20.94;
                                              left = 2.63;
                                          }
                                          return LearningCircle(
                                            label: label,
                                            left: left,
                                            top: top,
                                            index: idx,
                                          );
                                        }).toList(),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 11),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Continue lesson",
                                    style: TextStyle(
                                      fontFamily: 'Rubik',
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF251504),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  ..._openedLessons.map((lesson) {
                                    final lessonId = lesson['id'];
                                    final progress = lessonId == 'signlanguage'
                                        ? _signlanguageProgress
                                        : (_bookProgress[lessonId] ?? '0%');
                                    return Column(
                                      children: [
                                        GestureDetector(
                                          onTap: () async {
                                            await _updateOpenedLessons(
                                              id: lessonId,
                                              title: lesson['title'],
                                              description: lesson['description'],
                                              image: lesson['image'],
                                            );
                                            if (lessonId.startsWith('book')) {
                                              await Navigator.push(
                                                context,
                                                MaterialPageRoute(builder: (context) => PreloadApp(bookId: lessonId)),
                                              );
                                              await _saveSingleLessonProgress(lessonId);
                                            } else if (lessonId == 'signlanguage') {
                                              await Navigator.push(
                                                context,
                                                MaterialPageRoute(builder: (context) => const VideoListScreen()),
                                              );
                                              await _saveSingleLessonProgress(lessonId);
                                            }
                                          },
                                          child: LessonCard(
                                            title: lesson['title'],
                                            description: lesson['description'],
                                            progress: progress,
                                            image: lesson['image'],
                                          ),
                                        ),
                                        const SizedBox(height: 20),
                                      ],
                                    );
                                  }).toList(),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                        Positioned(
                          left: -14,
                          top: -280,
                          child: Image.asset(
                            'assets/curve1.png',
                            width: 450,
                            height: 27,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          left: -14,
                          top: -20,
                          child: Image.asset(
                            'assets/curve1.png',
                            width: 450,
                            height: 7,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          left: 1,
                          top: -190.5,
                          child: Image.asset(
                            'assets/finalgif.gif',
                            width: 370,
                            height: 170,
                            fit: BoxFit.cover,
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
      ),
    );
  }
}

class InterestCard extends StatelessWidget {
  final String title;
  final Color color;
  final Color borderColor;
  final String image;
  final bool isSelected;
  final VoidCallback onTap;

  const InterestCard({
    super.key,
    required this.title,
    required this.color,
    required this.borderColor,
    required this.image,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 125,
        height: 144,
        decoration: BoxDecoration(
          color: color,
          border: Border.all(color: borderColor),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Color(0x99B7AF9A).withOpacity(0.3),
              offset: Offset(0, 5),
              blurRadius: 10,
            ),
          ],
        ),
        child: Stack(
          children: [
            if (isSelected)
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    colors: [
                      Color.fromARGB(255, 106, 236, 70).withOpacity(1),
                      Color.fromARGB(255, 173, 250, 175).withOpacity(1),
                      const Color.fromARGB(0, 12, 0, 0),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    stops: [1, 1, 1],
                  ),
                ),
                margin: EdgeInsets.all(0.8),
              ),
            Column(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  child: Container(
                    height: 94,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: image.startsWith('assets/') ? AssetImage(image) : NetworkImage(image),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Rubik',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF251504),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class Dot extends StatelessWidget {
  final Color color;

  const Dot({super.key, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 7,
      height: 7,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }
}

class LearningCircle extends StatelessWidget {
  final String label;
  final double left;
  final double top;
  final int index;

  const LearningCircle({
    super.key,
    required this.label,
    required this.left,
    required this.top,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final Color circleColor = index % 2 == 0 ? const Color(0xFFFFECB3) : const Color(0xFFFFCDD2);
    final Color borderColor = index % 2 == 0 ? const Color(0xFF00897B) : const Color(0xFFD81B60);
    return Positioned(
      left: left,
      top: top,
      child: Column(
        children: [
          Container(
            width: 65,
            height: 65,
            decoration: BoxDecoration(
              color: circleColor,
              border: Border.all(color: borderColor, width: 5),
              borderRadius: BorderRadius.circular(100),
              boxShadow: const [
                BoxShadow(
                  color: Color(0xFFEEEEEE),
                  offset: Offset(0, 4),
                  blurRadius: 4,
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Image.asset(
                  'assets/${index + 1}.png',
                  width: 40,
                  height: 40,
                  fit: BoxFit.contain,
                ),
              ],
            ),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Rubik',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF251504),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class LessonCard extends StatelessWidget {
  final String title;
  final String description;
  final String progress;
  final String image;

  const LessonCard({
    super.key,
    required this.title,
    required this.description,
    required this.progress,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    double progressValue = double.tryParse(progress.replaceAll('%', ''))?.clamp(0.0, 100.0) ?? 0.0;

    return VisibilityDetector(
      key: Key('lesson-card-$title'),
      onVisibilityChanged: (visibilityInfo) {},
      child: Container(
        width: 382,
        height: 120,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFF6F6F6)),
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Color(0x44B7AF9A),
              offset: Offset(0, 10),
              blurRadius: 16.9,
            ),
          ],
        ),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(10),
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  image: DecorationImage(
                    image: image.startsWith('assets/') ? AssetImage(image) : NetworkImage(image),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'Rubik',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF251504),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    description,
                    style: const TextStyle(
                      fontFamily: 'Rubik',
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF87837B),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: AnimatedPieChart(
                progress: progressValue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AnimatedPieChart extends StatefulWidget {
  final double progress;

  const AnimatedPieChart({super.key, required this.progress});

  @override
  _AnimatedPieChartState createState() => _AnimatedPieChartState();
}

class _AnimatedPieChartState extends State<AnimatedPieChart> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _hasAnimated = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: widget.progress).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(AnimatedPieChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress) {
      _animation = Tween<double>(begin: 0.0, end: widget.progress).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
      );
      _hasAnimated = false;
    }
  }

  void _startAnimation() {
    if (!_hasAnimated) {
      _controller.reset();
      _controller.forward();
      _hasAnimated = true;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: Key('pie-chart-${widget.progress}'),
      onVisibilityChanged: (visibilityInfo) {
        if (visibilityInfo.visibleFraction > 0.5 && !_hasAnimated) {
          _startAnimation();
        }
      },
      child: SizedBox(
        width: 50,
        height: 50,
        child: Stack(
          alignment: Alignment.center,
          children: [
            AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return CustomPaint(
                  painter: PieChartPainter(
                    progress: _animation.value,
                  ),
                  child: Container(),
                );
              },
            ),
            Text(
              '${widget.progress.toStringAsFixed(0)}%',
              style: const TextStyle(
                fontFamily: 'Rubik',
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PieChartPainter extends CustomPainter {
  final double progress;

  PieChartPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final paint = Paint()..style = PaintingStyle.fill;

    paint.color = Colors.white;
    canvas.drawCircle(center, radius, paint);

    paint.color = const Color(0xFFF34F27);
    double sweepAngle = (progress / 100) * 2 * pi;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      sweepAngle,
      true,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class GameCard extends StatelessWidget {
  final String title;
  final String image;

  const GameCard({super.key, required this.title, required this.image});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x44B7AF9A),
            offset: Offset(0, 10),
            blurRadius: 16.9,
          ),
        ],
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: Image.asset(
              image,
              height: 100,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Rubik',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF251504),
            ),
          ),
        ],
      ),
    );
  }
}

class NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback? onTap;

  const NavItem({
    super.key,
    required this.icon,
    required this.label,
    this.isActive = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 70,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: isActive
                  ? BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFFFFC045),
                          Color(0xFFF3561A),
                          Color(0xFF6A1966),
                          Color(0xFF320432),
                        ],
                      ),
                      border: Border.all(color: const Color(0xFFDB4827), width: 2),
                    )
                  : null,
              child: Icon(
                icon,
                color: isActive ? Colors.white : const Color(0xFF87837B),
                size: 28,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Rubik',
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: isActive ? const Color(0xFF251504) : const Color(0xFF87837B),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}