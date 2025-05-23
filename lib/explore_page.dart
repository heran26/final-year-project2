import 'package:flutter/material.dart';
import 'library_page.dart'; // Assuming LessonCard and other necessary components are here or in home_page
import 'book_reader.dart'; // Contains PreloadApp
import 'book_assets.dart'; // Contains BookConfig, hardcodedBooks, fetchAdminBooks
import 'package:flutter_application_1/home_page.dart' as home; // Ensure LessonCard is accessible if it's from here
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'games_page.dart'; // Import GameConfig, hardcodedGames, gameModuleMapping
import 'amharic_letter.dart';
import 'english_letter.dart';
import 'space_game.dart';
import 'numbers_game.dart';
import 'signlanguage_game.dart';
import 'progress_calculate.dart'; // For ProgressCalculator

class ExplorePage extends StatefulWidget {
  const ExplorePage({Key? key}) : super(key: key);

  @override
  _ExplorePageState createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  List<BookConfig> _allBooks = [];
  List<GameConfig> _allGames = hardcodedGames;
  Map<String, String> _bookProgress = {};
  Map<String, double> _gameProgress = {'science': 0.0, 'math': 0.0, 'language': 0.0, 'ESL': 0.0};
  bool _isLoading = true;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  // Define modules with their properties matching HomePage InterestCards
  final List<Map<String, dynamic>> _modules = [
    {
      'title': 'Nature',
      'color': const Color(0xFFE6FFA2),
      'borderColor': const Color.fromARGB(255, 67, 93, 0),
      'image': 'assets/image3.png',
    },
    {
      'title': 'English',
      'color': const Color(0xFFFCE2B9),
      'borderColor': const Color.fromARGB(255, 64, 40, 1),
      'image': 'assets/image.png',
    },
    {
      'title': 'Science',
      'color': const Color(0xFFCBECFF),
      'borderColor': const Color.fromARGB(255, 0, 39, 63),
      'image': 'assets/science1.png',
    },
    {
      'title': 'Amharic',
      'color': const Color.fromARGB(255, 248, 172, 244),
      'borderColor': const Color.fromARGB(222, 83, 0, 81),
      'image': 'assets/cover1.png',
    },
    {
      'title': 'ESL',
      'color': const Color.fromARGB(255, 166, 248, 232),
      'borderColor': const Color.fromARGB(255, 0, 55, 53),
      'image': 'assets/signlanguage.jpg',
    },
    {
      'title': 'Math',
      'color': const Color.fromARGB(255, 165, 247, 151),
      'borderColor': const Color.fromARGB(255, 1, 86, 5),
      'image': 'assets/math.gif',
    },
    {
      'title': 'Cooking',
      'color': const Color.fromARGB(255, 245, 175, 175),
      'borderColor': const Color.fromARGB(255, 164, 1, 39),
      'image': 'assets/cooking.jpg',
    },
    {
      'title': 'Adventure',
      'color': const Color.fromARGB(255, 255, 255, 162),
      'borderColor': const Color.fromARGB(255, 103, 99, 0),
      'image': 'assets/adventure.jpg',
    },
    {
      'title': 'New',
      'color': const Color(0xFFFFECB3),
      'borderColor': const Color(0xFF00897B),
      'image': 'assets/new.jpg',
    },
  ];

  // Mapping of bookId to multiple modules
  final Map<String, List<String>> _moduleMapping = {
    'book1': ['Science', 'Nature', 'New'],
    'book2': ['English', 'ESL'],
    'book3': ['Math', 'Science'],
    'book4': ['Cooking', 'Adventure', 'New'],
    'book5': ['Amharic', 'English'],
  };

  @override
  void initState() {
    super.initState();
    _loadBooksAndProgress();
    _loadGameProgress();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  Future<void> _loadBooksAndProgress() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final adminBooks = await fetchAdminBooks();
      _allBooks = [...hardcodedBooks, ...adminBooks];

      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _bookProgress = {};
        for (var book in _allBooks) {
          double progress = prefs.getDouble('${book.bookId}_progress') ?? 0.0;
          _bookProgress[book.bookId] = '${progress.toStringAsFixed(0)}%';
        }
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading books or progress: $e');
      setState(() {
        _allBooks = hardcodedBooks;
        _isLoading = false;
      });
    }
  }

  Future<void> _loadGameProgress() async {
    final progress = await ProgressCalculator.getAllProgress();
    setState(() {
      _gameProgress = progress;
    });
    print('ExplorePage: Loaded game progress: $_gameProgress');
  }

  Future<void> _updateOpenedLessons({
    required String id,
    required String title,
    required String description,
    required String image,
    required String progress,
    required String category,
    required String module,
    required String type, // 'book' or 'game'
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<Map<String, dynamic>> openedLessons = [];

      String? lessonsJson = prefs.getString('opened_lessons');
      if (lessonsJson != null) {
        try {
          openedLessons = List<Map<String, dynamic>>.from(jsonDecode(lessonsJson));
        } catch (e) {
          print('Error decoding opened_lessons: $e');
          openedLessons = [];
        }
      }

      openedLessons.removeWhere((lesson) => lesson['id'] == id);

      openedLessons.add({
        'id': id,
        'title': title,
        'description': description,
        'image': image,
        'progress': progress,
        'category': category,
        'module': module,
        'type': type,
        'opened_at': DateTime.now().toIso8601String(),
      });

      if (openedLessons.length > 5) {
        openedLessons.sort((a, b) => DateTime.parse(b['opened_at']).compareTo(DateTime.parse(a['opened_at'])));
        openedLessons = openedLessons.sublist(0, 5);
      }

      await prefs.setString('opened_lessons', jsonEncode(openedLessons));
    } catch (e) {
      print('Error updating opened lessons: $e');
    }
  }

  List<dynamic> _getSearchResults() {
    if (_searchQuery.isEmpty) return [];

    List<dynamic> results = [];

    for (var module in _modules) {
      if (module['title'].toLowerCase().contains(_searchQuery)) {
        results.add({'type': 'module', 'data': module});
      }
    }

    for (var book in _allBooks) {
      if (book.title.toLowerCase().contains(_searchQuery)) {
        results.add({'type': 'book', 'data': book});
      }
    }

    for (var game in _allGames) {
      if (game.title.toLowerCase().contains(_searchQuery)) {
        results.add({'type': 'game', 'data': game});
      }
    }

    return results;
  }

  void _handleSearchResultTap(dynamic result) async {
    if (result['type'] == 'module') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ModuleBooksPage(
            module: result['data']['title'],
            books: _allBooks,
            bookProgress: _bookProgress,
            games: _allGames,
            gameProgress: _gameProgress,
            moduleMapping: _moduleMapping,
            gameModuleMapping: gameModuleMapping,
          ),
        ),
      );
    } else if (result['type'] == 'book') {
      final book = result['data'] as BookConfig;
      await _updateOpenedLessons(
        id: book.bookId,
        title: book.title,
        description: book.description,
        image: book.coverImage, // Changed to coverImage
        progress: _bookProgress[book.bookId] ?? '0%',
        category: book.category,
        module: book.module,
        type: 'book',
      );
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => PreloadApp(bookId: book.bookId)),
      );
      await _loadBooksAndProgress();
    } else if (result['type'] == 'game') {
      final game = result['data'] as GameConfig;
      await _updateOpenedLessons(
        id: game.gameId,
        title: game.title,
        description: game.description,
        image: game.coverImage,
        progress: '${(_gameProgress[game.category.toLowerCase()] ?? 0.0).toStringAsFixed(1)}%',
        category: game.category,
        module: game.module,
        type: 'game',
      );
      await _navigateToGame(game);
      await _loadGameProgress();
    }
  }

  Future<void> _navigateToGame(GameConfig game) async {
    final prefs = await SharedPreferences.getInstance();
    final category = game.category.toLowerCase();
    final currentCount = prefs.getInt('${category}_count') ?? 0;
    final newCount = currentCount + 1;
    await prefs.setInt('${category}_count', newCount);
    final startTime = DateTime.now().millisecondsSinceEpoch;
    await prefs.setInt('${category}_start_time', startTime);

    Widget gamePage;
    switch (game.gameId) {
      case 'amharic_letters':
        gamePage = AmharicLetterGame();
        break;
      case 'english_letters':
        gamePage = EnglishLetterGame();
        break;
      case 'space_exploration':
        gamePage = SpaceGame();
        break;
      case 'numbers':
        gamePage = NumbersGame();
        break;
      case 'esl':
        gamePage = GameScreen();
        break;
      default:
        return;
    }

    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => gamePage),
    );

    final endTime = DateTime.now().millisecondsSinceEpoch;
    final durationMs = endTime - startTime;
    final durationSeconds = (durationMs / 1000).toDouble();
    await ProgressCalculator.updateGameTime(category, durationSeconds);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchResults = _getSearchResults();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F1E5),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Explore",
                      style: TextStyle(
                        fontFamily: 'Rubik',
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF251504),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: "Search topics, books, or games...",
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
                      ),
                      style: const TextStyle(fontFamily: 'Rubik', fontSize: 16),
                    ),
                    const SizedBox(height: 20),
                    if (_searchQuery.isNotEmpty && searchResults.isNotEmpty)
                      Container(
                        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.3),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x44B7AF9A),
                              offset: Offset(0, 5),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: searchResults.length,
                          itemBuilder: (context, index) {
                            final result = searchResults[index];
                            final title = result['type'] == 'module'
                                ? result['data']['title']
                                : result['data'].title;
                            return ListTile(
                              title: Text(
                                title,
                                style: const TextStyle(
                                  fontFamily: 'Rubik',
                                  fontSize: 16,
                                  color: Color(0xFF251504),
                                ),
                              ),
                              subtitle: Text(
                                result['type'] == 'module'
                                    ? 'Module'
                                    : (result['type'] == 'book' ? 'Book' : 'Game'),
                                style: const TextStyle(
                                  fontFamily: 'Rubik',
                                  fontSize: 12,
                                  color: Color(0xFF87837B),
                                ),
                              ),
                              onTap: () => _handleSearchResultTap(result),
                            );
                          },
                        ),
                      ),
                    if (_searchQuery.isNotEmpty && searchResults.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20.0),
                        child: Center(
                          child: Text(
                            'No results found for "$_searchQuery"',
                            style: const TextStyle(
                              fontFamily: 'Rubik',
                              fontSize: 16,
                              color: Color(0xFF87837B),
                            ),
                          ),
                        ),
                      ),
                    if (_searchQuery.isEmpty)
                      _isLoading
                          ? const Center(child: CircularProgressIndicator(color: Color(0xFF251504)))
                          : GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 15,
                                mainAxisSpacing: 15,
                                childAspectRatio: 125 / 144, // Match InterestCard aspect ratio
                              ),
                              itemCount: _modules.length,
                              itemBuilder: (context, index) {
                                final module = _modules[index];
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ModuleBooksPage(
                                          module: module['title'],
                                          books: _allBooks,
                                          bookProgress: _bookProgress,
                                          games: _allGames,
                                          gameProgress: _gameProgress,
                                          moduleMapping: _moduleMapping,
                                          gameModuleMapping: gameModuleMapping,
                                        ),
                                      ),
                                    );
                                  },
                                  child: ModuleCard(
                                    title: module['title'],
                                    color: module['color'],
                                    borderColor: module['borderColor'],
                                    image: module['image'],
                                  ),
                                );
                              },
                            ),
                  ],
                ),
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
              right: 0,
              top: 10,
              child: Image.asset(
                'assets/Vector2.png',
                width: 23.31,
                height: 22.71,
                fit: BoxFit.cover,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ModuleCard extends StatelessWidget {
  final String title;
  final Color color;
  final Color borderColor;
  final String image;

  const ModuleCard({
    Key? key,
    required this.title,
    required this.color,
    required this.borderColor,
    required this.image,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 125, // Match InterestCard width
      height: 144, // Match InterestCard height
      decoration: BoxDecoration(
        color: color,
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0x99B7AF9A).withOpacity(0.3), // Match InterestCard shadow opacity
            offset: const Offset(0, 5),
            blurRadius: 10,
          ),
        ],
      ),
      child: Stack(
        children: [
          Column(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)), // Match InterestCard
                child: Container(
                  height: 120, // Match InterestCard image height
                  width: double.infinity,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: image.startsWith('assets/')
                          ? AssetImage(image) as ImageProvider
                          : NetworkImage(image),
                      fit: BoxFit.cover, // Match InterestCard fit
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10), // Match InterestCard spacing
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Rubik',
                  fontSize: 17, // Match InterestCard font size
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF251504),
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class GameCard extends StatelessWidget {
  final String title;
  final String imagePath;
  final double imageWidth;
  final double imageHeight;
  final double imageLeft;
  final double imageTop;
  final double progress;

  const GameCard({
    super.key,
    required this.title,
    required this.imagePath,
    required this.imageWidth,
    required this.imageHeight,
    required this.imageLeft,
    required this.imageTop,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      height: 130,
      decoration: BoxDecoration(
        color: const Color(0xFF87837B), // Changed to white to match book list
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x44B7AF9A),
            offset: Offset(0, 10),
            blurRadius: 16.9,
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            left: 0,
            right: 0,
            top: 20,
            child: Text(
              title,
              style: const TextStyle(
                fontFamily: 'Rubik',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF251504), // Changed to dark color for readability
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Positioned(
            left: imageLeft,
            top: imageTop,
            child: Image.asset(
              imagePath,
              width: imageWidth,
              height: imageHeight,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }
}

class ModuleBooksPage extends StatelessWidget {
  final String module;
  final List<BookConfig> books;
  final Map<String, String> bookProgress;
  final List<GameConfig> games;
  final Map<String, double> gameProgress;
  final Map<String, List<String>> moduleMapping;
  final Map<String, List<String>> gameModuleMapping;

  const ModuleBooksPage({
    Key? key,
    required this.module,
    required this.books,
    required this.bookProgress,
    required this.games,
    required this.gameProgress,
    required this.moduleMapping,
    required this.gameModuleMapping,
  }) : super(key: key);

  Future<void> _updateOpenedLessons(
    BuildContext context, {
    required String id,
    required String title,
    required String description,
    required String image,
    required String progress,
    required String category,
    required String module,
    required String type,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<Map<String, dynamic>> openedLessons = [];

      String? lessonsJson = prefs.getString('opened_lessons');
      if (lessonsJson != null) {
        try {
          openedLessons = List<Map<String, dynamic>>.from(jsonDecode(lessonsJson));
        } catch (e) {
          print('Error decoding opened_lessons: $e');
          openedLessons = [];
        }
      }

      openedLessons.removeWhere((lesson) => lesson['id'] == id);

      openedLessons.add({
        'id': id,
        'title': title,
        'description': description,
        'image': image,
        'progress': progress,
        'category': category,
        'module': module,
        'type': type,
        'opened_at': DateTime.now().toIso8601String(),
      });

      if (openedLessons.length > 5) {
        openedLessons.sort((a, b) => DateTime.parse(b['opened_at']).compareTo(DateTime.parse(a['opened_at'])));
        openedLessons = openedLessons.sublist(0, 5);
      }

      await prefs.setString('opened_lessons', jsonEncode(openedLessons));
    } catch (e) {
      print('Error updating opened lessons: $e');
    }
  }

  Future<void> _navigateToGame(
    BuildContext context,
    GameConfig game,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final category = game.category.toLowerCase();
    final currentCount = prefs.getInt('${category}_count') ?? 0;
    final newCount = currentCount + 1;
    await prefs.setInt('${category}_count', newCount);
    final startTime = DateTime.now().millisecondsSinceEpoch;
    await prefs.setInt('${category}_start_time', startTime);

    Widget gamePage;
    switch (game.gameId) {
      case 'amharic_letters':
        gamePage = AmharicLetterGame();
        break;
      case 'english_letters':
        gamePage = EnglishLetterGame();
        break;
      case 'space_exploration':
        gamePage = SpaceGame();
        break;
      case 'numbers':
        gamePage = NumbersGame();
        break;
      case 'esl':
        gamePage = GameScreen();
        break;
      default:
        return;
    }

    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => gamePage),
    );

    final endTime = DateTime.now().millisecondsSinceEpoch;
    final durationMs = endTime - startTime;
    final durationSeconds = (durationMs / 1000).toDouble();
    await ProgressCalculator.updateGameTime(category, durationSeconds);
  }

  @override
  Widget build(BuildContext context) {
    final normalizedModule = module.toLowerCase();

    final moduleBooks = books.where((book) {
      List<String> bookAssociatedModules = moduleMapping[book.bookId] ?? [book.module];
      bool matchesCurrentModule = bookAssociatedModules.any((m) => m.toLowerCase() == normalizedModule);
      bool isNewModuleAndBookIsExplicitlyNew = (normalizedModule == 'new' && bookAssociatedModules.contains('New'));
      return matchesCurrentModule || isNewModuleAndBookIsExplicitlyNew;
    }).toList();

    final moduleGames = games.where((game) {
      List<String> gameAssociatedModules = gameModuleMapping[game.gameId] ?? [game.module];
      bool matchesCurrentModule = gameAssociatedModules.any((m) => m.toLowerCase() == normalizedModule);
      bool isNewModuleAndGameIsExplicitlyNew = (normalizedModule == 'new' && gameAssociatedModules.contains('New'));
      return matchesCurrentModule || isNewModuleAndGameIsExplicitlyNew;
    }).toList();

    final allItems = [
      ...moduleBooks.map((book) => {'type': 'book', 'data': book}),
      ...moduleGames.map((game) => {'type': 'game', 'data': game}),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF7F1E5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F1E5),
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF251504)),
        title: Text(
          module[0].toUpperCase() + module.substring(1),
          style: const TextStyle(
            fontFamily: 'Rubik',
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Color(0xFF251504),
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: allItems.isEmpty
                    ? Center(
                        child: Text(
                          'No books or games available in this module yet.\nCheck back soon! 🧸',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            fontFamily: 'Rubik',
                            color: Colors.grey[700],
                            height: 1.5,
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: allItems.length,
                        itemBuilder: (context, index) {
                          final item = allItems[index];
                          if (item['type'] == 'book') {
                            final book = item['data'] as BookConfig;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: GestureDetector(
                                onTap: () async {
                                  await _updateOpenedLessons(
                                    context,
                                    id: book.bookId,
                                    title: book.title,
                                    description: book.description,
                                    image: book.coverImage, // Changed to coverImage
                                    progress: bookProgress[book.bookId] ?? '0%',
                                    category: book.category,
                                    module: book.module,
                                    type: 'book',
                                  );
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => PreloadApp(bookId: book.bookId)),
                                  );
                                },
                                child: LessonCard(
                                  title: book.title,
                                  description: book.description,
                                  progress: bookProgress[book.bookId] ?? '0%',
                                  image: book.coverImage, // Changed to coverImage
                                  category: book.category,
                                ),
                              ),
                            );
                          } else {
                            final game = item['data'] as GameConfig;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: GestureDetector(
                                onTap: () async {
                                  await _updateOpenedLessons(
                                    context,
                                    id: game.gameId,
                                    title: game.title,
                                    description: game.description,
                                    image: game.coverImage,
                                    progress: '${(gameProgress[game.category.toLowerCase()] ?? 0.0).toStringAsFixed(1)}%',
                                    category: game.category,
                                    module: game.module,
                                    type: 'game',
                                  );
                                  await _navigateToGame(context, game);
                                },
                                child: GameCard(
                                  title: game.title,
                                  imagePath: game.coverImage,
                                  imageWidth: 80,
                                  imageHeight: 80,
                                  imageLeft: 10,
                                  imageTop: 10,
                                  progress: gameProgress[game.category.toLowerCase()] ?? 0.0,
                                ),
                              ),
                            );
                          }
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}