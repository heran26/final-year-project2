import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'amharic_letter.dart'; // Import Amharic game
import 'space_game.dart'; // Import Space game
import 'numbers_game.dart'; // Import Numbers game

class GamesPage extends StatelessWidget {
  static const platform = MethodChannel('com.example.flutter_application_1/unity');

  Future<void> _startUnity() async {
    try {
      String result = await platform.invokeMethod('startUnity');
      print(result); // "Unity Launched"
    } on PlatformException catch (e) {
      print("Failed to launch Unity: '${e.message}'.");
    }
  }

  void _navigateToAmharicGame(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AmharicLetterGame()),
    );
  }

  void _navigateToSpaceGame(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SpaceGame()),
    );
  }

  void _navigateToNumbersGame(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => NumbersGame()),
    );
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
        backgroundColor: Color(0xFFF7F1E5),
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
                padding: EdgeInsets.all(24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(height: 20),
                          Expanded(
                            child: SingleChildScrollView(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Transform.rotate(
                                    angle: 90 * 3.14159 / 180,
                                    child: GestureDetector(
                                      onTap: () => _navigateToAmharicGame(context),
                                      child: GameCard(
                                        title: "Amharic letter",
                                        imagePath: 'assets/cover1.png',
                                        imageWidth: 160, // Example width
                                        imageHeight: 160, // Example height
                                        imageLeft: 20, // Example left position
                                        imageTop: 40, // Example top position
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 40),
                                  Transform.rotate(
                                    angle: 90 * 3.14159 / 180,
                                    child: GestureDetector(
                                      onTap: () => _navigateToSpaceGame(context),
                                      child: GameCard(
                                        title: "Space Exploration",
                                        imagePath: 'assets/cover2.jpg',
                                        imageWidth: 250, // Example width
                                        imageHeight: 350, // Example height
                                        imageLeft: -30, // Example left position
                                        imageTop: -50, // Example top position
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 40),
                                  Transform.rotate(
                                    angle: 90 * 3.14159 / 180,
                                    child: GestureDetector(
                                      onTap: () => _navigateToNumbersGame(context),
                                      child: GameCard(
                                        title: "Numbers",
                                        imagePath: 'assets/cover3.jpg',
                                        imageWidth: 160, // Example width
                                        imageHeight: 170, // Example height
                                        imageLeft: 15, // Example left position
                                        imageTop: 35, // Example top position
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
                      padding: EdgeInsets.only(left: 10, top: 20),
                      child: Transform.rotate(
                        angle: 90 * 3.14159 / 180,
                        child: Text(
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
  final String imagePath; // Path to the image asset for this card
  final double imageWidth; // Width of the image
  final double imageHeight; // Height of the image
  final double imageLeft; // Left position of the image
  final double imageTop; // Top position of the image

  GameCard({
    required this.title,
    required this.imagePath,
    required this.imageWidth,
    required this.imageHeight,
    required this.imageLeft,
    required this.imageTop,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Color(0x44B7AF9A),
            offset: Offset(0, 10),
            blurRadius: 16.9,
          ),
        ],
      ),
      child: Stack(
        children: [
          // Title at the top with padding
          Positioned(
            left: 0,
            right: 0,
            top: 20,
            child: Text(
              title,
              style: TextStyle(
                fontFamily: 'Rubik',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          // Image with manual positioning
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