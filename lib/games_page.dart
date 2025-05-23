import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'progress_calculate.dart';
import 'amharic_letter.dart';
import 'space_game.dart';
import 'numbers_game.dart';
import 'signlanguage_game.dart';
import 'english_letter.dart';

class GameConfig {
  final String gameId;
  final String title;
  final String description;
  final String coverImage;
  final String category;
  final String module;

  GameConfig({
    required this.gameId,
    required this.title,
    required this.description,
    required this.coverImage,
    required this.category,
    required this.module,
  });
}

final List<GameConfig> hardcodedGames = [
  GameConfig(
    gameId: 'amharic_letters',
    title: 'Amharic Letters',
    description: 'Learn Amharic letters through fun activities',
    coverImage: 'assets/cover1.png',
    category: 'Language',
    module: 'Amharic',
  ),
  GameConfig(
    gameId: 'english_letters',
    title: 'English Letters',
    description: 'Practice English alphabet with interactive games',
    coverImage: 'assets/cover2.png',
    category: 'Language',
    module: 'English',
  ),
  GameConfig(
    gameId: 'space_exploration',
    title: 'Space Exploration',
    description: 'Explore the universe with exciting challenges',
    coverImage: 'assets/cover2.jpg',
    category: 'Science',
    module: 'Science',
  ),
  GameConfig(
    gameId: 'numbers',
    title: 'Numbers',
    description: 'Master numbers through engaging math games',
    coverImage: 'assets/cover3.jpg',
    category: 'Math',
    module: 'Math',
  ),
  GameConfig(
    gameId: 'esl',
    title: 'ESL',
    description: 'Learn sign language basics',
    coverImage: 'assets/signlanguage.jpg',
    category: 'ESL',
    module: 'ESL',
  ),
];

final Map<String, List<String>> gameModuleMapping = {
  'amharic_letters': ['Amharic', 'Language'],
  'english_letters': ['English', 'Language'],
  'space_exploration': ['Science', 'Adventure', 'New'],
  'numbers': ['Math'],
  'esl': ['ESL'],
};

class GamesPage extends StatefulWidget {
  const GamesPage({super.key});

  @override
  _GamesPageState createState() => _GamesPageState();
}

class _GamesPageState extends State<GamesPage> {
  static const platform = MethodChannel('com.example.flutter_application_1/unity');
  Map<String, double> _progress = {'science': 0.0, 'math': 0.0, 'language': 0.0, 'ESL': 0.0};

  @override
  void initState() {
    super.initState();
    _loadProgress();
    _logSharedPreferences();
  }

  Future<void> _loadProgress() async {
    final progress = await ProgressCalculator.getAllProgress();
    setState(() {
      _progress = progress;
    });
    print('GamesPage: Loaded progress: $_progress');
  }

  Future<void> _logSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = [
      'science_count',
      'math_count',
      'language_count',
      'ESL_count',
      'science_game_time',
      'math_game_time',
      'language_game_time',
      'ESL_game_time',
      'science_start_time',
      'math_start_time',
      'language_start_time',
      'ESL_start_time',
    ];
    for (final key in keys) {
      final value = prefs.get(key);
      print('GamesPage: SharedPreferences[$key] = $value');
    }
  }

  Future<void> _startUnity() async {
    try {
      String result = await platform.invokeMethod('startUnity');
      print(result);
    } on PlatformException catch (e) {
      print("Failed to launch Unity: '${e.message}'.");
    }
  }

  Future<void> _navigateToGame(
    BuildContext context,
    Widget gamePage,
    String category,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    print('GamesPage: Navigating to $category game');

    final currentCount = prefs.getInt('${category}_count') ?? 0;
    final newCount = currentCount + 1;
    await prefs.setInt('${category}_count', newCount);
    print('GamesPage: $category press count updated to $newCount');

    final startTime = DateTime.now().millisecondsSinceEpoch;
    await prefs.setInt('${category}_start_time', startTime);

    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => gamePage),
    );

    final endTime = DateTime.now().millisecondsSinceEpoch;
    final durationMs = endTime - startTime;
    final durationSeconds = (durationMs / 1000).toDouble();

    await ProgressCalculator.updateGameTime(category, durationSeconds);
    print('GamesPage: $category game session duration: $durationSeconds seconds');

    await _loadProgress();
    await _logSharedPreferences();
  }

  void _navigateToLanguageGame(BuildContext context) {
    _navigateToGame(context, AmharicLetterGame(), 'language');
  }

  void _navigateToLanguageGame2(BuildContext context) {
    _navigateToGame(context, EnglishLetterGame(), 'language');
  }

  void _navigateToScienceGame(BuildContext context) {
    _navigateToGame(context, SpaceGame(), 'science');
  }

  void _navigateToMathGame(BuildContext context) {
    _navigateToGame(context, NumbersGame(), 'math');
  }

  void _navigateToESLGame(BuildContext context) {
    _navigateToGame(context, GameScreen(), 'ESL');
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    return WillPopScope(
      onWillPop: () async {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
        return true;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F1E5),
        body: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/back.png',
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),
                          Expanded(
                            child: SingleChildScrollView(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Transform.rotate(
                                    angle: 90 * 3.14159 / 180,
                                    child: GestureDetector(
                                      onTap: () => _navigateToLanguageGame(context),
                                      child: GameCard(
                                        title: "Amharic Letters",
                                        imagePath: 'assets/cover1.png',
                                        imageWidth: 160,
                                        imageHeight: 160,
                                        imageLeft: 20,
                                        imageTop: 40,
                                        progress: _progress['language'] ?? 0.0,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 40),
                                  Transform.rotate(
                                    angle: 90 * 3.14159 / 180,
                                    child: GestureDetector(
                                      onTap: () => _navigateToLanguageGame2(context),
                                      child: GameCard(
                                        title: "English Letters",
                                        imagePath: 'assets/cover2.png',
                                        imageWidth: 160,
                                        imageHeight: 160,
                                        imageLeft: 20,
                                        imageTop: 40,
                                        progress: _progress['language'] ?? 0.0,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 40),
                                  Transform.rotate(
                                    angle: 90 * 3.14159 / 180,
                                    child: GestureDetector(
                                      onTap: () => _navigateToScienceGame(context),
                                      child: GameCard(
                                        title: "Space Exploration",
                                        imagePath: 'assets/cover2.jpg',
                                        imageWidth: 250,
                                        imageHeight: 350,
                                        imageLeft: -30,
                                        imageTop: -50,
                                        progress: _progress['science'] ?? 0.0,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 40),
                                  Transform.rotate(
                                    angle: 90 * 3.14159 / 180,
                                    child: GestureDetector(
                                      onTap: () => _navigateToMathGame(context),
                                      child: GameCard(
                                        title: "Numbers",
                                        imagePath: 'assets/cover3.jpg',
                                        imageWidth: 160,
                                        imageHeight: 170,
                                        imageLeft: 15,
                                        imageTop: 35,
                                        progress: _progress['math'] ?? 0.0,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 40),
                                  Transform.rotate(
                                    angle: 90 * 3.14159 / 180,
                                    child: GestureDetector(
                                      onTap: () => _navigateToESLGame(context),
                                      child: GameCard(
                                        title: "ESL",
                                        imagePath: 'assets/signlanguage.jpg',
                                        imageWidth: 160,
                                        imageHeight: 170,
                                        imageLeft: 15,
                                        imageTop: 35,
                                        progress: _progress['ESL'] ?? 0.0,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10, top: 20),
                      child: Transform.rotate(
                        angle: 90 * 3.14159 / 180,
                        child: const Text(
                          "Games",
                          style: TextStyle(
                            fontFamily: 'Rubik',
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF251504),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
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
      height: 200,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
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
                color: Colors.white,
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
          Positioned(
            left: 0,
            right: 0,
            bottom: 20,
            child: Text(
              'Progress: ${progress.toStringAsFixed(1)}%',
              style: const TextStyle(
                fontFamily: 'Rubik',
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}