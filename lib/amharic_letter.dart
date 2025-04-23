import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';
import 'package:audioplayers/audioplayers.dart';

class AmharicLetterGame extends StatefulWidget {
  @override
  _AmharicLetterGameState createState() => _AmharicLetterGameState();
}

class _AmharicLetterGameState extends State<AmharicLetterGame> with SingleTickerProviderStateMixin {
  bool _showChar1 = true;
  bool _showHaInTarget = false;
  Timer? _timer;
  String _selectedAlphabet = 'ሀ'; // Default base alphabet
  List<String> _associatedLetters = []; // Letters associated with the selected alphabet
  String _currentLetterImage = 'ሀ'; // Track the current letter image (base or associated)

  // Animation-related variables for birds.gif
  late AnimationController _animationController;
  late Animation<double> _birdsAnimation;

  // Variables for GIF sequence control
  String _currentGif = 'shake'; // Tracks which GIF to show: 'shake' or 'stand'
  int _standLoopCount = 0; // Counts loops of stand.gif
  int _gifKey = 0; // To force reload of GIFs

  // Audio player instance
  final AudioPlayer _audioPlayer = AudioPlayer();

  final Map<String, List<String>> _alphabetMap = {
    'ሀ': ['ሀ', 'ሁ', 'ሂ', 'ሃ', 'ሄ', 'ህ', 'ሆ'],
    'ለ': ['ለ', 'ሉ', 'ሊ', 'ላ', 'ሌ', 'ል', 'ሎ'],
    'ሐ': ['ሐ', 'ሑ', 'ሒ', 'ሓ', 'ሔ', 'ሕ', 'ሖ'],
    'መ': ['መ', 'ሙ', 'ሚ', 'ማ', 'ሜ', 'ም', 'ሞ'],
    'ሠ': ['ሠ', 'ሡ', 'ሢ', 'ሣ', 'ሤ', 'ሥ', 'ሦ'],
    'ረ': ['ረ', 'ሩ', 'ሪ', 'ራ', 'ሬ', 'ር', 'ሮ'],
    'ሰ': ['ሰ', 'ሱ', 'ሲ', 'ሳ', 'ሴ', 'ስ', 'ሶ'],
    'ሸ': ['ሸ', 'ሹ', 'ሺ', 'ሻ', 'ሼ', 'ሽ', 'ሾ'],
    'ቀ': ['ቀ', 'ቁ', 'ቂ', 'ቃ', 'ቄ', 'ቅ', 'ቆ'],
    'በ': ['በ', 'ቡ', 'ቢ', 'ባ', 'ቤ', 'ብ', 'ቦ'],
    'ተ': ['ተ', 'ቱ', 'ቲ', 'ታ', 'ቴ', 'ት', 'ቶ'],
    'ቸ': ['ቸ', 'ቹ', 'ቺ', 'ቻ', 'ቼ', 'ች', 'ቾ'],
    'ኀ': ['ኀ', 'ኁ', 'ኂ', 'ኃ', 'ኄ', 'ኅ', 'ኆ'],
    'ነ': ['ነ', 'ኑ', 'ኒ', 'ና', 'ኔ', 'ን', 'ኖ'],
    'ኘ': ['ኘ', 'ኙ', 'ኚ', 'ኛ', 'ኜ', 'ኝ', 'ኞ'],
    'አ': ['አ', 'ኡ', 'ኢ', 'ኣ', 'ኤ', 'እ', 'ኦ'],
    'ከ': ['ከ', 'ኩ', 'ኪ', 'ካ', 'ኬ', 'ክ', 'ኮ'],
    'ኸ': ['ኸ', 'ኹ', 'ኺ', 'ኻ', 'ኼ', 'ኽ', 'ኾ'],
    'ወ': ['ወ', 'ዉ', 'ዊ', 'ዋ', 'ዌ', 'ው', 'ዎ'],
    'ዐ': ['ዐ', 'ዑ', 'ዒ', 'ዓ', 'ዔ', 'ዕ', 'ዖ'],
    'ዘ': ['ዘ', 'ዙ', 'ዚ', 'ዛ', 'ዜ', 'ዝ', 'ዞ'],
    'ዠ': ['ዠ', 'ዡ', 'ዢ', 'ዣ', 'ዤ', 'ዥ', 'ዦ'],
    'የ': ['የ', 'ዩ', 'ዪ', 'ያ', 'ዬ', 'ይ', 'ዮ'],
    'ደ': ['ደ', 'ዱ', 'ዲ', 'ዳ', 'ዴ', 'ድ', 'ዶ'],
    'ጀ': ['ጀ', 'ጁ', 'ጂ', 'ጃ', 'ጄ', 'ጅ', 'ጆ'],
    'ገ': ['ገ', 'ጉ', 'ጊ', 'ጋ', 'ጌ', 'ግ', 'ጎ'],
    'ጠ': ['ጠ', 'ጡ', 'ጢ', 'ጣ', 'ጤ', 'ጥ', 'ጦ'],
    'ጨ': ['ጨ', 'ጩ', 'ጪ', 'ጫ', 'ጬ', 'ጭ', 'ጮ'],
    'ጰ': ['ጰ', 'ጱ', 'ጲ', 'ጳ', 'ጴ', 'ጵ', 'ጶ'],
    'ጸ': ['ጸ', 'ጹ', 'ጺ', 'ጻ', 'ጼ', 'ጽ', 'ጾ'],
    'ፀ': ['ፀ', 'ፁ', 'ፂ', 'ፃ', 'ፄ', 'ፅ', 'ፆ'],
    'ፈ': ['ፈ', 'ፉ', 'ፊ', 'ፋ', 'ፌ', 'ፍ', 'ፎ'],
    'ፐ': ['ፐ', 'ፑ', 'ፒ', 'ፓ', 'ፔ', 'ፕ', 'ፖ'],
  };

  final double _haTargetX = 140;
  final double _haTargetY = 290;

  @override
  void initState() {
    super.initState();
    _associatedLetters = _alphabetMap[_selectedAlphabet] ?? [];
    _currentLetterImage = 'ሀ';

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

  void _onTap() {
    if (_timer == null || !_timer!.isActive) {
      setState(() {
        _showChar1 = false;
        _showHaInTarget = true;
      });

      _audioPlayer.play(AssetSource('$_currentLetterImage.m4a'));

      _timer = Timer(const Duration(milliseconds: 1100), () {
        setState(() {
          _showChar1 = true;
          _showHaInTarget = false;
        });
      });
    }
  }

  void _onAlphabetSelected(String alphabet) {
    setState(() {
      _selectedAlphabet = alphabet;
      _associatedLetters = List.from(_alphabetMap[alphabet] ?? []);
      _currentLetterImage = alphabet;
    });
  }

  void _onAssociatedLetterSelected(String letter) {
    setState(() {
      _currentLetterImage = letter;
    });
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
        onTap: _onTap,
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
                  left: _showHaInTarget ? _haTargetX : screenWidth * 0.25,
                  top: _showHaInTarget ? _haTargetY : screenHeight * 0.13,
                  child: Transform.rotate(
                    angle: pi / 2,
                    child: Image.asset(
                      'assets/$_currentLetterImage.png',
                      width: _showHaInTarget ? 140 : 70,
                      height: _showHaInTarget ? 140 : 70,
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: screenWidth,
                    height: 70,
                    child: ListView(
                      reverse: true,
                      scrollDirection: Axis.horizontal,
                      children: [
                        for (var alphabet in _alphabetMap.keys)
                          _buildAlphabetButton(alphabet),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 70,
                    height: screenHeight,
                    child: ListView(
                      scrollDirection: Axis.vertical,
                      children: [
                        for (var letter in _associatedLetters)
                          _buildAssociatedLetterButton(letter),
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

  Widget _buildAlphabetButton(String alphabet) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Transform.rotate(
        angle: pi / 2,
        child: ElevatedButton(
          onPressed: () {
            _onAlphabetSelected(alphabet);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: _selectedAlphabet == alphabet ? Colors.orange : Colors.purple,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.all(15),
            elevation: 5,
            shadowColor: Colors.deepPurple,
          ),
          child: Text(
            alphabet,
            style: const TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _buildAssociatedLetterButton(String letter) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Transform.rotate(
        angle: pi / 2,
        child: ElevatedButton(
          onPressed: () {
            _onAssociatedLetterSelected(letter);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: _currentLetterImage == letter ? Colors.greenAccent : Colors.green,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.all(15),
            elevation: 5,
            shadowColor: Colors.deepPurple,
          ),
          child: Text(
            letter,
            style: const TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
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