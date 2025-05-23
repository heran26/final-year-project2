import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';
import 'package:audioplayers/audioplayers.dart';

class EnglishLetterGame extends StatefulWidget {
  @override
  _EnglishLetterGameState createState() => _EnglishLetterGameState();
}

class _EnglishLetterGameState extends State<EnglishLetterGame> with SingleTickerProviderStateMixin {
  bool _showChar1 = true;
  bool _showLetterInTarget = false;
  Timer? _timer;
  String _currentLetter = 'A'; // Track the current letter to display

  // Animation-related variables for birds.gif
  late AnimationController _animationController;
  late Animation<double> _birdsAnimation;

  // Variables for GIF sequence control
  String _currentGif = 'shake'; // Tracks which GIF to show: 'shake' or 'stand'
  int _standLoopCount = 0; // Counts loops of stand.gif
  int _gifKey = 0; // To force reload of GIFs

  // Audio player instance
  final AudioPlayer _audioPlayer = AudioPlayer();

  // List of English letters
  final List<String> _letters = List.generate(26, (index) => String.fromCharCode('A'.codeUnitAt(0) + index));

  final double _targetX = 140;
  final double _targetY = 290;

  @override
  void initState() {
    super.initState();
    _currentLetter = 'A';

    // Initialize animation for birds.gif
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    // Start the GIF sequence
    _startGifSequence();
  }

  void _startGifSequence() {
    const shakeDuration = Duration(seconds: 3);
    const standDuration = Duration(seconds: 2);
    const standLoops = 3;

    void sequenceStep() {
      setState(() {
        _gifKey++;
      });

      if (_currentGif == 'shake') {
        Future.delayed(shakeDuration, () {
          if (mounted) {
            setState(() {
              _currentGif = 'stand';
              _standLoopCount = 0;
            });
            sequenceStep();
          }
        });
      } else if (_currentGif == 'stand') {
        Future.delayed(standDuration, () {
          if (mounted) {
            setState(() {
              _standLoopCount++;
            });
            if (_standLoopCount < standLoops) {
              sequenceStep();
            } else {
              setState(() {
                _currentGif = 'shake';
              });
              sequenceStep();
            }
          }
        });
      }
    }

    sequenceStep();
  }

  void _triggerAnimation() {
    if (_timer == null || !_timer!.isActive) {
      setState(() {
        _showChar1 = false;
        _showLetterInTarget = true;
      });

      _audioPlayer.play(AssetSource('${_currentLetter.toLowerCase()}.m4a'));

      _timer = Timer(const Duration(milliseconds: 1100), () {
        if (mounted) {
          setState(() {
            _showChar1 = true;
            _showLetterInTarget = false;
          });
        }
      });
    }
  }

  void _onLetterSelected(String letter) {
    setState(() {
      _currentLetter = letter;
    });
    _triggerAnimation(); // Play animation when letter is selected
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animationController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: _triggerAnimation, // Allow screen tap to replay animation
        child: LayoutBuilder(
          builder: (context, constraints) {
            double screenWidth = constraints.maxWidth;
            double screenHeight = constraints.maxHeight;

            _birdsAnimation = Tween<double>(
              begin: screenHeight + 150,
              end: -150,
            ).animate(
              CurvedAnimation(parent: _animationController, curve: Curves.linear),
            );

            return Stack(
              children: [
                Positioned.fill(
                  child: Transform.rotate(
                    angle: pi / 2,
                    child: Transform.scale(
                      scale: _calculateScale(screenWidth, screenHeight),
                      child: Image.asset(
                        'assets/background.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
                AnimatedBuilder(
                  animation: _birdsAnimation,
                  builder: (context, child) {
                    return Positioned(
                      left: screenWidth * 0.4,
                      top: _birdsAnimation.value,
                      child: Transform.rotate(
                        angle: pi / 2,
                        child: Image.asset(
                          'assets/birds.gif',
                          width: 300,
                          height: 300,
                          fit: BoxFit.contain,
                        ),
                      ),
                    );
                  },
                ),
                Positioned(
                  left: 0,
                  top: screenHeight * 0.05,
                  child: Transform.rotate(
                    angle: pi / 2,
                    child: Image.asset(
                      'assets/sign.png',
                      width: 200,
                      height: 200,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                Positioned(
                  left: 115,
                  top: screenHeight * 0.1,
                  child: Transform.rotate(
                    angle: pi / 2,
                    child: Image.asset(
                      'assets/bird.gif',
                      width: 150,
                      height: 150,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                if (_showChar1)
                  Positioned(
                    left: -150,
                    top: 150,
                    child: Transform.rotate(
                      angle: pi / 2,
                      child: Image.asset(
                        _currentGif == 'shake' ? 'assets/shake.gif' : 'assets/stand.gif',
                        width: 600,
                        height: 600,
                        fit: BoxFit.contain,
                        key: ValueKey(_gifKey),
                      ),
                    ),
                  ),
                if (!_showChar1)
                  Positioned(
                    left: -234,
                    top: 190,
                    child: Transform.rotate(
                      angle: pi / 2,
                      child: Image.asset(
                        'assets/signn.gif',
                        width: 600,
                        height: 600,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                Positioned(
                  left: _showLetterInTarget ? _targetX : screenWidth * 0.25,
                  top: _showLetterInTarget ? _targetY : screenHeight * 0.13,
                  child: Transform.rotate(
                    angle: pi / 2,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Image.asset(
                          'assets/blank.png',
                          width: _showLetterInTarget ? 140 : 70,
                          height: _showLetterInTarget ? 140 : 70,
                          fit: BoxFit.fill,
                        ),
                        CustomPaint(
                          size: Size(_showLetterInTarget ? 140 : 70, _showLetterInTarget ? 140 : 70),
                          painter: LetterPainter(
                            letter: _currentLetter,
                            fontSize: _showLetterInTarget ? 170 : 90,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    width: 70,
                    height: screenHeight,
                    child: ListView(
                      scrollDirection: Axis.vertical,
                      children: [
                        for (var letter in _letters)
                          _buildLetterButton(letter),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildLetterButton(String letter) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Transform.rotate(
        angle: pi / 2,
        child: ElevatedButton(
          key: ValueKey(letter), // Unique key for each button
          onPressed: () {
            _onLetterSelected(letter);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: _currentLetter == letter ? Colors.orange : Colors.purple,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.all(15),
            elevation: 5,
            shadowColor: Colors.deepPurple,
          ),
          child: Text(
            letter,
            style: const TextStyle(fontSize: 44, color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  double _calculateScale(double screenWidth, double screenHeight) {
    double imageWidth = screenHeight;
    double imageHeight = screenWidth;
    double scaleWidth = screenWidth / imageWidth;
    double scaleHeight = screenHeight / imageHeight;
    return max(scaleWidth, scaleHeight);
  }
}

class LetterPainter extends CustomPainter {
  final String letter;
  final double fontSize;

  LetterPainter({required this.letter, required this.fontSize});

  @override
  void paint(Canvas canvas, Size size) {
    final textStyle = TextStyle(
      color: Colors.black,
      fontSize: fontSize,
      fontWeight: FontWeight.bold,
      fontFamily: 'Roboto', // Use a standard font for English letters
    );

    final textSpan = TextSpan(
      text: letter,
      style: textStyle,
    );

    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();

    final offset = Offset(
      (size.width - textPainter.width) / 2,
      (size.height - textPainter.height) / 2,
    );

    textPainter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}