import 'package:flutter/material.dart';
import 'dart:async'; // For Timer

class NumbersGame extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: ImageScroll(),
      ),
    );
  }
}

class ImageScroll extends StatefulWidget {
  @override
  _ImageScrollState createState() => _ImageScrollState();
}

class _ImageScrollState extends State<ImageScroll> with SingleTickerProviderStateMixin {
  bool showLion1 = true;
  bool showOne = false; // Controls visibility of one.png (from lion)
  bool showElephant1 = true; // Non-flipped elephant
  bool showElephant1Flipped = true; // Flipped elephant
  int elephantTouchCount = 0; // Tracks unique elephant touches (0, 1, or 2)
  bool lastTouchedWasFlipped = false; // Tracks which elephant was last touched
  bool showNumberOne = false; // Controls visibility of one.png (for counting)
  bool showNumberTwo = false; // Controls visibility of two.png (for counting)
  late AnimationController _controller;
  late Animation<double> _animation;

  // Background images
  final List<String> imagePaths = [
    'assets/no1.png',
    'assets/no2.jpg',
    'assets/no3.jpg',
    'assets/no4.jpg',
    'assets/no5.jpg',
    'assets/no6.jpg',
  ];

  // Positions for one.png (from lion)
  final double oneAnimationStartLeft = 100;
  final double oneAnimationEndLeft = 250;
  final double oneRestingTop = 150;

  // Positions for number labels (near elephants)
  final double numberLeft = 200;
  final double numberTop = 450;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _animation = Tween<double>(
      begin: oneAnimationStartLeft,
      end: oneAnimationEndLeft,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  void toggleLionImages() {
    setState(() {
      showLion1 = false;
      showOne = true;
      elephantTouchCount = 0; // Reset elephant count
      showNumberOne = false;
      showNumberTwo = false;
    });
    _controller.forward(from: 0);

    Timer(Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          showLion1 = true;
          showOne = false;
          _controller.reset();
        });
      }
    });
  }

  void toggleElephantImages(bool isFlipped) {
    setState(() {
      if (isFlipped) {
        showElephant1Flipped = false; // Animate flipped elephant
      } else {
        showElephant1 = false; // Animate non-flipped elephant
      }

      // Counting logic
      if (elephantTouchCount == 0) {
        // First touch, always show one.png
        elephantTouchCount = 1;
        showNumberOne = true;
        showNumberTwo = false;
        lastTouchedWasFlipped = isFlipped;
      } else if (elephantTouchCount == 1) {
        if (lastTouchedWasFlipped == isFlipped) {
          // Same elephant touched again, reset to one.png
          elephantTouchCount = 1;
          showNumberOne = true;
          showNumberTwo = false;
        } else {
          // Different elephant touched, show two.png
          elephantTouchCount = 2;
          showNumberOne = false;
          showNumberTwo = true;
          lastTouchedWasFlipped = isFlipped;
        }
      } else if (elephantTouchCount == 2) {
        // Third touch after two unique elephants, reset to one.png
        elephantTouchCount = 1;
        showNumberOne = true;
        showNumberTwo = false;
        lastTouchedWasFlipped = isFlipped;
      }
    });

    Timer(Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          if (isFlipped) {
            showElephant1Flipped = true;
          } else {
            showElephant1 = true;
          }
          showNumberOne = false; // Hide number after animation
          showNumberTwo = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Stack(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: imagePaths
                .map((path) => Image.asset(
                      path,
                      fit: BoxFit.contain,
                      width: double.infinity,
                    ))
                .toList(),
          ),
          Positioned(
            left: 1,
            top: 50,
            child: GestureDetector(
              onTap: toggleLionImages,
              child: Image.asset(
                showLion1 ? 'assets/lion.png' : 'assets/lion2.png',
                width: 250,
                height: 250,
              ),
            ),
          ),
          if (showOne)
            Positioned(
              left: _animation.value,
              top: oneRestingTop,
              child: Image.asset(
                'assets/one.png',
                width: 80,
                height: 80,
              ),
            ),
          Positioned(
            left: 220,
            top: 100,
            child: Image.asset(
              'assets/hut.png',
              width: 150,
              height: 150,
            ),
          ),
          Positioned(
            left: 220,
            top: 220,
            child: Image.asset(
              'assets/adeyabeba.png',
              width: 80,
              height: 80,
            ),
          ),
          Positioned(
            left: 220,
            top: 270,
            child: Image.asset(
              'assets/adeyabeba.png',
              width: 80,
              height: 80,
            ),
          ),
          Positioned(
            left: 229,
            top: 38,
            child: Image.asset(
              'assets/adeyabeba.png',
              width: 80,
              height: 80,
            ),
          ),
          Positioned(
            left: 220,
            top: 347,
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.diagonal3Values(1, -1, 1),
              child: Image.asset(
                'assets/adeyabeba.png',
                width: 80,
                height: 80,
              ),
            ),
          ),
          // Non-flipped elephant
          Positioned(
            left: 20,
            top: 420,
            child: GestureDetector(
              onTap: () => toggleElephantImages(false),
              child: Image.asset(
                showElephant1 ? 'assets/elephant.png' : 'assets/elephant2.png',
                width: 180,
                height: 180,
              ),
            ),
          ),
          // Flipped elephant
          Positioned(
            left: 20,
            top: 640,
            child: GestureDetector(
              onTap: () => toggleElephantImages(true),
              child: Transform(
                alignment: Alignment.center,
                transform: Matrix4.diagonal3Values(1, -1, 1),
                child: Image.asset(
                  showElephant1Flipped ? 'assets/elephant.png' : 'assets/elephant2.png',
                  width: 180,
                  height: 180,
                ),
              ),
            ),
          ),
          // Number labels
          if (showNumberOne)
            Positioned(
              left: numberLeft,
              top: numberTop,
              child: Image.asset(
                'assets/one.png',
                width: 80,
                height: 80,
              ),
            ),
          if (showNumberTwo)
            Positioned(
              left: numberLeft,
              top: numberTop,
              child: Image.asset(
                'assets/two.png',
                width: 80,
                height: 80,
              ),
            ),
        ],
      ),
    );
  }
}