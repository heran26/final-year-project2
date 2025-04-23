import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late ScrollController _scrollController;
  int _activeSlide = 0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_updateActiveSlide);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF7F1E5),
      body: SafeArea( // Added SafeArea to respect top/bottom system UI
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 20, left: 24, right: 24), // Reduced top padding
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
                                      Text(
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
                                        " USER!",
                                        style: TextStyle(
                                          fontFamily: 'Rubik',
                                          fontSize: 20,
                                          fontWeight: FontWeight.w900,
                                          color: Color(0xFFDB4827),
                                          height: 1.625,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    "Let's learn something new today!",
                                    style: TextStyle(
                                      fontFamily: 'Rubik',
                                      fontSize: 13,
                                      fontWeight: FontWeight.w400,
                                      color: Color(0xFF87837B),
                                      height: 1.3846,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                width: 65,
                                height: 63,
                                decoration: BoxDecoration(
                                  color: Color(0xFFFF8BE0),
                                  border: Border.all(color: Colors.black, width: 5),
                                  borderRadius: BorderRadius.circular(100),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Color(0xFFEEEEEE),
                                      offset: Offset(0, 4),
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(100),
                                  child: Image.asset(
                                    'assets/avatar8.png',
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
                  SizedBox(height: 7),
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 11),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Choose interests",
                                      style: TextStyle(
                                        fontFamily: 'Rubik',
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF251504),
                                      ),
                                    ),
                                    Text(
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
                                SizedBox(height: 20),
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  controller: _scrollController,
                                  child: Row(
                                    children: [
                                      InterestCard(
                                        title: "Nature",
                                        color: Color(0xFFE6FFA2),
                                        borderColor: Color(0xFFCBEA7B),
                                        image: 'assets/image3.png',
                                      ),
                                      SizedBox(width: 10),
                                      InterestCard(
                                        title: "English",
                                        color: Color(0xFFFCE2B9),
                                        borderColor: Color(0xFFEDD0A2),
                                        image: 'assets/image.png',
                                      ),
                                      SizedBox(width: 10),
                                      InterestCard(
                                        title: "Science",
                                        color: Color(0xFFCBECFF),
                                        borderColor: Color(0xFFB9D3E3),
                                        image: 'assets/science1.png',
                                      ),
                                      SizedBox(width: 10),
                                      InterestCard(
                                        title: "Nature",
                                        color: Color(0xFFE6FFA2),
                                        borderColor: Color(0xFFCBEA7B),
                                        image: 'assets/nature_image.png',
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 20),
                          Center(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Dot(color: _activeSlide == 0 ? Color(0xFF251504) : Color(0xFFA9A391)),
                                SizedBox(width: 12),
                                Dot(color: _activeSlide == 1 ? Color(0xFF251504) : Color(0xFFA9A391)),
                                SizedBox(width: 12),
                                Dot(color: _activeSlide == 2 ? Color(0xFF251504) : Color(0xFFA9A391)),
                                SizedBox(width: 12),
                                Dot(color: _activeSlide == 3 ? Color(0xFF251504) : Color(0xFFA9A391)),
                              ],
                            ),
                          ),
                          SizedBox(height: 20),
                          Padding(
                            padding: EdgeInsets.only(left: 14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Padding(
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
                                    SizedBox(width: 122),
                                    Transform.rotate(
                                      angle: 55.19 * 3.14159 / 180,
                                      child: Container(
                                        width: 3.57,
                                        height: 7.29,
                                        color: Color(0x33FFFFFF),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 5),
                                Container(
                                  width: 382.17,
                                  height: 352.31,
                                  child: Stack(
                                    children: [
                                      Positioned(
                                        left: 72.76,
                                        top: 79.01,
                                        child: Image.asset(
                                          'assets/Vector.png',
                                          width: 230.31,
                                          height: 220.71,
                                        ),
                                      ),
                                      LearningCircle(
                                        label: "ESL",
                                        left: 2.63,
                                        top: 20.94,
                                        index: 0,
                                      ),
                                      LearningCircle(
                                        label: "Writing",
                                        left: 106.65,
                                        top: 74.24,
                                        index: 1,
                                      ),
                                      LearningCircle(
                                        label: "Reading",
                                        left: 154.23,
                                        top: 199.50,
                                        index: 2,
                                      ),
                                      LearningCircle(
                                        label: "Cooking",
                                        left: 289.31,
                                        top: 228.88,
                                        index: 3,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 11),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Continue lesson",
                                  style: TextStyle(
                                    fontFamily: 'Rubik',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF251504),
                                  ),
                                ),
                                SizedBox(height: 20),
                                LessonCard(
                                  title: "Kekkihy",
                                  description: "long established fact that a reader .",
                                  progress: "68%",
                                  image: 'assets/lesson_image.png',
                                ),
                                SizedBox(height: 20),
                                LessonCard(
                                  title: "Kekkihy",
                                  description: "long established fact that a reader .",
                                  progress: "68%",
                                  image: 'assets/lesson_image2.png',
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 20), // Reduced significantly to avoid overlap
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
    );
  }
}

class InterestCard extends StatelessWidget {
  final String title;
  final Color color;
  final Color borderColor;
  final String image;

  InterestCard({
    required this.title,
    required this.color,
    required this.borderColor,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 125,
      height: 144,
      decoration: BoxDecoration(
        color: color,
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Color(0x99B7AF9A),
            offset: Offset(0, 23),
            blurRadius: 16.9,
          ),
        ],
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            child: Container(
              height: 94,
              width: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(image),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          SizedBox(height: 10),
          Text(
            title,
            style: TextStyle(
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

class Dot extends StatelessWidget {
  final Color color;

  Dot({required this.color});

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

  LearningCircle({
    required this.label,
    required this.left,
    required this.top,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left,
      top: top,
      child: Column(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: Color(0xFFD1C4CE),
              border: Border.all(color: Color(0xFF7A7979), width: 5),
              borderRadius: BorderRadius.circular(100),
              boxShadow: [
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
          SizedBox(height: 5),
          Text(
            label,
            style: TextStyle(
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

  LessonCard({
    required this.title,
    required this.description,
    required this.progress,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 382,
      height: 125,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Color(0xFFF6F6F6)),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
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
            padding: EdgeInsets.all(10),
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                image: DecorationImage(
                  image: AssetImage(image),
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
                  style: TextStyle(
                    fontFamily: 'Rubik',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF251504),
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  description,
                  style: TextStyle(
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
            padding: EdgeInsets.all(10),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFE5E5E5),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x49898274),
                        blurRadius: 4,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFFEF8D1B),
                        Color(0xFFF34F27),
                        Color(0xFF6E1664),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
                Text(
                  progress,
                  style: TextStyle(
                    fontFamily: 'Rubik',
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF87837B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class GameCard extends StatelessWidget {
  final String title;
  final String image;

  GameCard({required this.title, required this.image});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
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
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            child: Image.asset(
              image,
              height: 100,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(height: 10),
          Text(
            title,
            style: TextStyle(
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

  NavItem({
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
          mainAxisSize: MainAxisSize.min, // Let content determine height
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: isActive
                  ? BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFFFFC045),
                          Color(0xFFF3561A),
                          Color(0xFF6A1966),
                          Color(0xFF320432),
                        ],
                      ),
                      border: Border.all(color: Color(0xFFDB4827), width: 2),
                    )
                  : null,
              child: Icon(
                icon,
                color: isActive ? Colors.white : Color(0xFF87837B),
                size: 28, // Kept larger size as requested
              ),
            ),
            SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Rubik',
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: isActive ? Color(0xFF251504) : Color(0xFF87837B),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}