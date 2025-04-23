import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

class SpaceGame extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Space Adventure',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: SpaceMissionScreen(),
    );
  }
}

// SpaceMissionScreen (First Screen)
class SpaceMissionScreen extends StatefulWidget {
  @override
  _SpaceMissionScreenState createState() => _SpaceMissionScreenState();
}

class _SpaceMissionScreenState extends State<SpaceMissionScreen> with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;
  late AnimationController _slideController;
  late Animation<Offset> _headSlideAnimation;
  late Animation<Offset> _bodySlideAnimation;

  bool _isCharr0Visible = true;
  bool _isCharr1Visible = true;
  bool _isHeadVisible = false;
  bool _isBodyVisible = false;
  bool _isCharr0Moved = false;
  bool _isCharr1Moved = false;
  bool _isCharr0Animating = true;
  bool _isCharr1Animating = true;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );

    _slideController = AnimationController(
      duration: Duration(seconds: 1),
      vsync: this,
    );

    _headSlideAnimation = Tween<Offset>(begin: Offset(1, 0), end: Offset(0, 0)).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeInOut),
    );

    _bodySlideAnimation = Tween<Offset>(begin: Offset(-1, 0), end: Offset(0, 0)).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeInOut),
    );
  }

  void _startCharr0Animation() {
    setState(() {
      _isCharr0Moved = true;
      _isCharr1Visible = false;
      _isHeadVisible = true;
      _isBodyVisible = true;
      _isCharr0Animating = false;
    });
    _scaleController.stop();
    _slideController.forward().then((_) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => RocketScreen()));
    });
  }

  void _startCharr1Animation() {
    setState(() {
      _isCharr1Moved = true;
      _isCharr0Visible = false;
      _isHeadVisible = true;
      _isBodyVisible = true;
      _isCharr1Animating = false;
    });
    _scaleController.stop();
    _slideController.forward().then((_) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => RocketScreen()));
    });
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(width: 402, height: 874, color: Colors.white),
          Positioned(
            left: -255,
            top: 227,
            child: Transform.rotate(
              angle: 1.5708,
              child: Image.asset('assets/spaceBG.jpg', width: 925, height: 427, fit: BoxFit.cover),
            ),
          ),
          Positioned(
            left: -193,
            top: 220,
            child: Transform.rotate(
              angle: 1.5708,
              child: Image.asset('assets/earth.png', width: 735, height: 339, fit: BoxFit.cover),
            ),
          ),
          Positioned(
            left: 88,
            top: 350,
            child: Transform.rotate(
              angle: 1.5708,
              child: Image.asset('assets/spacemission.png', width: 457, height: 149, fit: BoxFit.cover),
            ),
          ),
          if (_isCharr0Visible)
            Positioned(
              left: 80,
              top: _isCharr0Moved ? 290 : 220,
              child: GestureDetector(
                onTap: _startCharr0Animation,
                child: _isCharr0Animating
                    ? ScaleTransition(
                        scale: _scaleAnimation,
                        child: Transform.rotate(
                          angle: 1.5708,
                          child: Image.asset('assets/charr0.png', width: 118, height: 234, fit: BoxFit.cover),
                        ),
                      )
                    : Transform.rotate(
                        angle: 1.5708,
                        child: Image.asset('assets/charr0.png', width: 118, height: 234, fit: BoxFit.cover),
                      ),
              ),
            ),
          if (_isCharr1Visible)
            Positioned(
              left: 80,
              top: _isCharr1Moved ? 300 : 350,
              child: GestureDetector(
                onTap: _startCharr1Animation,
                child: _isCharr1Animating
                    ? ScaleTransition(
                        scale: _scaleAnimation,
                        child: Transform.rotate(
                          angle: 1.5708,
                          child: Image.asset('assets/charr1.png', width: 104, height: 210, fit: BoxFit.cover),
                        ),
                      )
                    : Transform.rotate(
                        angle: 1.5708,
                        child: Image.asset('assets/charr1.png', width: 104, height: 210, fit: BoxFit.cover),
                      ),
              ),
            ),
          if (_isBodyVisible)
            Positioned(
              left: 5,
              top: 198,
              child: SlideTransition(
                position: _bodySlideAnimation,
                child: Transform.rotate(
                  angle: 1.5708,
                  child: Image.asset('assets/body.png', width: 400, height: 400, fit: BoxFit.cover),
                ),
              ),
            ),
          if (_isHeadVisible)
            Positioned(
              left: 160,
              top: 330,
              child: SlideTransition(
                position: _headSlideAnimation,
                child: Transform.rotate(
                  angle: 1.5708,
                  child: Image.asset('assets/head.png', width: 130, height: 130, fit: BoxFit.cover),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// RocketScreen (Second Screen)
class RocketScreen extends StatefulWidget {
  @override
  _RocketScreenState createState() => _RocketScreenState();
}

class _RocketScreenState extends State<RocketScreen> {
  Offset _rocket1Pos = Offset(120, 425);
  Offset _rocket2Pos = Offset(89, 3);
  late Offset _rocket3Pos;
  Offset _rocket1DuplicatePos = Offset(120, -135);

  final Offset _rocket1OriginalPos = Offset(120, 425);
  final Offset _rocket2OriginalPos = Offset(89, 3);
  late Offset _rocket3OriginalPos;
  final Offset _rocket1DuplicateOriginalPos = Offset(120, -135);

  final Offset _rocket1TargetPos = Offset(120, 345);
  final Offset _rocket2TargetPos = Offset(89, 243);
  late Offset _rocket3TargetPos;
  final Offset _rocket1DuplicateTargetPos = Offset(120, 105);

  bool _isRocket1Placed = false;
  bool _isRocket2Placed = false;
  bool _isRocket3Placed = false;
  bool _isRocket1DuplicatePlaced = false;

  final double _snapThreshold = 50.0;

  Offset _convertToOffset(double right, double bottom, double width, double height, Size screenSize) {
    double left = screenSize.width - width - right;
    double top = screenSize.height - height - bottom;
    return Offset(left, top);
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    _rocket3OriginalPos = _convertToOffset(100, -150, 190, 450, screenSize);
    _rocket3TargetPos = _convertToOffset(100, 150, 190, 450, screenSize);
    _rocket3Pos = _isRocket3Placed ? _rocket3TargetPos : _rocket3OriginalPos;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_isRocket1Placed && _isRocket2Placed && _isRocket3Placed && _isRocket1DuplicatePlaced) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => FlightScreen()));
      }
    });

    return Scaffold(
      body: Stack(
        children: [
          Container(width: double.infinity, height: double.infinity, color: Colors.white),
          Positioned(
            left: -255,
            top: 227,
            child: Transform.rotate(
              angle: 1.5708,
              child: Image.asset('assets/spaceBG.jpg', width: 925, height: 427, fit: BoxFit.cover),
            ),
          ),
          Positioned(left: 160, top: 112, child: _rotatedImage('assets/dashrocket.png', 64, 357)),
          Positioned(left: -23, top: 175, child: _rotatedImage('assets/dashed3.png', 400, 489)),
          Positioned(right: 10, top: 170, child: _rotatedImage('assets/dashed2.png', 250, 499)),
          Positioned(right: 160, bottom: 75, child: _rotatedImage('assets/dashrocket.png', 64, 357)),
          if (!_isRocket3Placed)
            Positioned(
              left: _rocket3Pos.dx,
              top: _rocket3Pos.dy,
              child: Draggable(
                data: 'rocket3',
                feedback: _rotatedImage('assets/rocket3.png', 190, 450, opacity: 0.7),
                childWhenDragging: Container(),
                child: _rotatedImage('assets/rocket3.png', 190, 450),
                onDragEnd: (details) => _handleDragEnd(details, 'rocket3'),
              ),
            ),
          if (_isRocket3Placed)
            Positioned(left: _rocket3Pos.dx, top: _rocket3Pos.dy, child: _rotatedImage('assets/rocket3.png', 190, 450)),
          if (!_isRocket1Placed)
            Positioned(
              left: _rocket1Pos.dx,
              top: _rocket1Pos.dy,
              child: Draggable(
                data: 'rocket1',
                feedback: _rotatedImage('assets/rocket.png', 182, 400, opacity: 0.7),
                childWhenDragging: Container(),
                child: _rotatedImage('assets/rocket.png', 182, 400),
                onDragEnd: (details) => _handleDragEnd(details, 'rocket1'),
              ),
            ),
          if (_isRocket1Placed)
            Positioned(left: _rocket1Pos.dx, top: _rocket1Pos.dy, child: _rotatedImage('assets/rocket.png', 182, 400)),
          if (!_isRocket1DuplicatePlaced)
            Positioned(
              left: _rocket1DuplicatePos.dx,
              top: _rocket1DuplicatePos.dy,
              child: Draggable(
                data: 'rocket1_duplicate',
                feedback: _rotatedImage('assets/rocket.png', 182, 400, opacity: 0.7),
                childWhenDragging: Container(),
                child: _rotatedImage('assets/rocket.png', 182, 400),
                onDragEnd: (details) => _handleDragEnd(details, 'rocket1_duplicate'),
              ),
            ),
          if (_isRocket1DuplicatePlaced)
            Positioned(
                left: _rocket1DuplicatePos.dx,
                top: _rocket1DuplicatePos.dy,
                child: _rotatedImage('assets/rocket.png', 182, 400)),
          if (!_isRocket2Placed)
            Positioned(
              left: _rocket2Pos.dx,
              top: _rocket2Pos.dy,
              child: Draggable(
                data: 'rocket2',
                feedback: _rotatedImage('assets/rocket2.png', 240, 339, opacity: 0.7),
                childWhenDragging: Container(),
                child: _rotatedImage('assets/rocket2.png', 240, 339),
                onDragEnd: (details) => _handleDragEnd(details, 'rocket2'),
              ),
            ),
          if (_isRocket2Placed)
            Positioned(left: _rocket2Pos.dx, top: _rocket2Pos.dy, child: _rotatedImage('assets/rocket2.png', 240, 339)),
        ],
      ),
    );
  }

  Widget _rotatedImage(String asset, double width, double height, {double opacity = 1.0}) {
    return Transform.rotate(
      angle: 1.5708,
      child: Opacity(opacity: opacity, child: Image.asset(asset, width: width, height: height, fit: BoxFit.contain)),
    );
  }

  void _handleDragEnd(DraggableDetails details, String rocketType) {
    final dropPosition = details.offset;
    setState(() {
      switch (rocketType) {
        case 'rocket1':
          if (_isCloseEnough(dropPosition, _rocket1TargetPos)) {
            _rocket1Pos = _rocket1TargetPos;
            _isRocket1Placed = true;
          } else {
            _rocket1Pos = _rocket1OriginalPos;
          }
          break;
        case 'rocket2':
          if (_isCloseEnough(dropPosition, _rocket2TargetPos)) {
            _rocket2Pos = _rocket2TargetPos;
            _isRocket2Placed = true;
          } else {
            _rocket2Pos = _rocket2OriginalPos;
          }
          break;
        case 'rocket3':
          if (_isCloseEnough(dropPosition, _rocket3TargetPos)) {
            _rocket3Pos = _rocket3TargetPos;
            _isRocket3Placed = true;
          } else {
            _rocket3Pos = _rocket3OriginalPos;
          }
          break;
        case 'rocket1_duplicate':
          if (_isCloseEnough(dropPosition, _rocket1DuplicateTargetPos)) {
            _rocket1DuplicatePos = _rocket1DuplicateTargetPos;
            _isRocket1DuplicatePlaced = true;
          } else {
            _rocket1DuplicatePos = _rocket1DuplicateOriginalPos;
          }
          break;
      }
    });
  }

  bool _isCloseEnough(Offset dropPosition, Offset targetPosition) {
    final dx = (dropPosition.dx - targetPosition.dx).abs();
    final dy = (dropPosition.dy - targetPosition.dy).abs();
    return dx < _snapThreshold && dy < _snapThreshold;
  }
}

// FlightScreen (Third Screen)
class FlightScreen extends StatefulWidget {
  @override
  _FlightScreenState createState() => _FlightScreenState();
}

class _FlightScreenState extends State<FlightScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _rocketAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: Duration(seconds: 5), vsync: this)..forward();
    _rocketAnimation = Tween<Offset>(begin: Offset(-1.0, 0.0), end: Offset(1.5, 0.0)).animate(
      CurvedAnimation(parent: _controller, curve: Curves.linear),
    );
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => IPhoneDesign()));
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
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            left: -255,
            top: 227,
            child: Transform.rotate(
              angle: 1.5708,
              child: Image.asset('assets/spaceBG.jpg', width: 925, height: 427, fit: BoxFit.cover),
            ),
          ),
          SlideTransition(
            position: _rocketAnimation,
            child: Center(
              child: Transform.rotate(
                angle: 1.5708,
                child: Image.asset('assets/fullrocket.png', width: 340, height: 600, fit: BoxFit.contain),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// IPhoneDesign (Fourth Screen - Solar System)
class IPhoneDesign extends StatefulWidget {
  @override
  _IPhoneDesignState createState() => _IPhoneDesignState();
}

class _IPhoneDesignState extends State<IPhoneDesign> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late AnimationController _sunController;
  bool isOn = true;
  bool isButton1 = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: Duration(milliseconds: 500))..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.85, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _sunController = AnimationController(vsync: this, duration: Duration(seconds: 4))..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    _sunController.dispose();
    super.dispose();
  }

  void _toggleSwitch() => setState(() => isOn = !isOn);
  void _toggleButton() => setState(() => isButton1 = !isButton1);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SizedBox(
          width: 402,
          height: 874,
          child: Stack(
            children: [
              Positioned(left: -245, top: 175, child: _buildRotatedImage('assets/bg.jpg', 904, 418, fit: BoxFit.cover)),
              Positioned(
                left: 157,
                top: 327,
                child: AnimatedBuilder(
                  animation: _sunController,
                  builder: (context, child) => Transform.rotate(
                    angle: _sunController.value * 2 * 3.14159,
                    child: Image.asset('assets/sun.png', width: 123, height: 126),
                  ),
                ),
              ),
              _buildTappablePlanet(left: 195, top: 431, asset: 'assets/mercury.png', width: 61, height: 76),
              _buildTappablePlanet(left: 188, top: 270, asset: 'assets/venus.png', width: 78, height: 77),
              _buildTappablePlanet(left: 129, top: 449, asset: 'assets/earth2.png', width: 81, height: 68),
              _buildTappablePlanet(left: 143, top: 229, asset: 'assets/mars.png', width: 75, height: 63),
              _buildTappablePlanet(left: 147, top: 512, asset: 'assets/jupiter.png', width: 123, height: 126),
              _buildTappablePlanet(left: 183, top: 129, asset: 'assets/saturn.png', width: 181, height: 168),
              _buildTappablePlanet(left: 243, top: 459, asset: 'assets/neptune.png', width: 111, height: 98),
              _buildTappablePlanet(left: 103, top: 141, asset: 'assets/uranus.png', width: 111, height: 98),
              Positioned(
                left: 5,
                top: 341,
                child: GestureDetector(
                  onTap: _toggleSwitch,
                  child: _buildRotatedImage(isOn ? 'assets/on.png' : 'assets/off.png', isOn ? 121 : 121, isOn ? 108 : 118),
                ),
              ),
              Positioned(
                left: -9,
                top: 431,
                child: GestureDetector(
                  onTap: _toggleButton,
                  child: _buildRotatedImage(isButton1 ? 'assets/button1.png' : 'assets/button2.png', 84, 71),
                ),
              ),
              Positioned(left: 70, top: 449, child: _buildRotatedImage('assets/ethflag.png', 64, 35)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTappablePlanet({required double left, required double top, required String asset, required double width, required double height}) {
    return Positioned(
      left: left,
      top: top,
      child: GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CollisionGame(selectedPlanetAsset: asset, planetWidth: width, planetHeight: height),
          ),
        ),
        child: AnimatedBuilder(
          animation: _animation,
          builder: (context, child) => Transform.rotate(
            angle: 1.5708,
            child: Transform.scale(scale: _animation.value, child: Image.asset(asset, width: width, height: height)),
          ),
        ),
      ),
    );
  }

  Widget _buildRotatedImage(String asset, double width, double height, {BoxFit? fit}) {
    return Transform.rotate(angle: 1.5708, child: Image.asset(asset, width: width, height: height, fit: fit));
  }
}

// CollisionGame (Fifth Screen)
class CollisionGame extends StatefulWidget {
  final String selectedPlanetAsset;
  final double planetWidth;
  final double planetHeight;

  const CollisionGame({required this.selectedPlanetAsset, required this.planetWidth, required this.planetHeight});

  @override
  _CollisionGameState createState() => _CollisionGameState();
}

class _CollisionGameState extends State<CollisionGame> with TickerProviderStateMixin {
  late AnimationController _backgroundController;
  late AnimationController _planetController;
  late Animation<double> _planetAnimation;
  double rocketX = 0.0;
  double rocketY = 0.0;

  final double backgroundLeftOffset = 0;
  final double backgroundTopOffset = 0;

  List<Map<String, dynamic>> _spaceObjects = [];
  late Timer _spawnTimer;
  final Random _random = Random();
  final double scrollSpeed = 5.0;

  final List<double> lanes = [-0.5, -0.25, 0.0, 0.25, 0.5];
  Set<double> occupiedLanes = {};

  bool _isExploding = false;
  double? _explosionLeft;
  double? _explosionTop;
  Timer? _explosionTimer;

  final double explosionOffsetX = 20.0;
  final double explosionOffsetY = 20.0;

  double health = 100.0;
  final double healthDecreasePerCollision = 20.0;

  bool _isGameOver = false;
  bool _reachedPlanet = false;
  bool _planetCentered = false;

  late Timer _progressTimer;
  double _progressValue = 0.0;
  final double _maxProgressTime = 30.0;

  String getPlanetName() {
    String asset = widget.selectedPlanetAsset;
    return asset.split('/').last.split('.').first.replaceAll('2', '').capitalize();
  }

  @override
  void initState() {
    super.initState();
    _backgroundController = AnimationController(vsync: this, duration: Duration(seconds: 5))..repeat();
    _planetController = AnimationController(vsync: this, duration: Duration(seconds: 2))
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          setState(() {
            _planetCentered = true;
            _backgroundController.stop();
          });
        }
      });
    _planetAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(CurvedAnimation(parent: _planetController, curve: Curves.easeOut));

    _progressTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_isGameOver || _reachedPlanet) {
        timer.cancel();
        return;
      }
      setState(() {
        _progressValue += 1.0;
        if (_progressValue >= _maxProgressTime) {
          _progressValue = _maxProgressTime;
          if (health > 0) _reachPlanet();
          else _gameOver();
        }
      });
    });

    _spawnInitialObjects();

    _backgroundController.addListener(() {
      if (_isGameOver || _planetCentered) return;
      setState(() {
        for (var obj in _spaceObjects) obj['x'] -= scrollSpeed / 1550;
        _spaceObjects.removeWhere((obj) {
          bool isOffScreen = obj['x'] < -0.1;
          if (isOffScreen) occupiedLanes.remove(obj['y']);
          return isOffScreen;
        });
        _checkCollisions();
      });
    });

    _spawnTimer = Timer.periodic(Duration(seconds: 2), (timer) {
      if (mounted && !_isGameOver && !_reachedPlanet) setState(() => _spawnSpaceObject());
    });
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    _planetController.dispose();
    _spawnTimer.cancel();
    _explosionTimer?.cancel();
    _progressTimer.cancel();
    super.dispose();
  }

  void _spawnInitialObjects() {
    List<double> availableLanes = List.from(lanes);
    for (int i = 0; i < min(5, availableLanes.length); i++) {
      final isMeteor = _random.nextBool();
      final imagePath = isMeteor ? 'assets/meteor.png' : 'assets/bluerocket.png';
      final double laneY = availableLanes.removeAt(_random.nextInt(availableLanes.length));
      final double startX = 0.8 + (i * 0.1);
      _spaceObjects.add({'imagePath': imagePath, 'x': startX, 'y': laneY});
      occupiedLanes.add(laneY);
    }
  }

  void _spawnSpaceObject() {
    List<double> availableLanes = lanes.where((lane) => !occupiedLanes.contains(lane)).toList();
    if (availableLanes.isEmpty) return;
    final isMeteor = _random.nextBool();
    final imagePath = isMeteor ? 'assets/meteor.png' : 'assets/bluerocket.png';
    final double laneY = availableLanes[_random.nextInt(availableLanes.length)];
    _spaceObjects.add({'imagePath': imagePath, 'x': 0.8, 'y': laneY});
    occupiedLanes.add(laneY);
  }

  void _moveRocket(DragUpdateDetails details, Orientation orientation) {
    if (_isGameOver) return;
    setState(() {
      if (orientation == Orientation.portrait) rocketY += details.delta.dy / 100;
      else rocketX += details.delta.dy / 100;
      rocketX = rocketX.clamp(-1.0, 1.0);
      rocketY = rocketY.clamp(-1.0, 1.0);
    });
  }

  void _checkCollisions() {
    final orientation = MediaQuery.of(context).orientation;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    const backgroundWidth = 1550.0;

    final double rocketWidth = 100;
    final double rocketHeight = 100;
    final double maxY = (screenHeight - rocketHeight) / 2;

    final double rocketLeft = 40;
    final double rocketTop = (screenHeight - rocketHeight) / 2 + (rocketY * maxY);

    final rocketRect = Rect.fromLTWH(rocketLeft, rocketTop, rocketWidth, rocketHeight);

    for (int i = 0; i < _spaceObjects.length; i++) {
      final obj = _spaceObjects[i];
      final double objLeft = backgroundLeftOffset + (obj['x'] * backgroundWidth);
      final double objTop = (screenHeight - 80) / 2 + (obj['y'] * (screenHeight / 2 - 40));
      final double objWidth = obj['imagePath'] == 'assets/bluerocket.png' ? 100 : 80;
      final double objHeight = obj['imagePath'] == 'assets/bluerocket.png' ? 100 : 80;

      final objRect = Rect.fromLTWH(objLeft, objTop, objWidth, objHeight);

      if (rocketRect.overlaps(objRect) && !_isExploding && !_isGameOver) {
        _spaceObjects.removeAt(i);
        occupiedLanes.remove(obj['y']);
        setState(() {
          health = (health - healthDecreasePerCollision).clamp(0.0, 100.0);
        });
        _startExplosion(rocketLeft, rocketTop);
        if (health <= 0) _gameOver();
        break;
      }
    }
  }

  void _startExplosion(double rocketLeft, double rocketTop) {
    _isExploding = true;
    _explosionLeft = rocketLeft + explosionOffsetX;
    _explosionTop = rocketTop + explosionOffsetY;
    _explosionTimer = Timer(Duration(milliseconds: 500), () {
      setState(() {
        _isExploding = false;
        _explosionLeft = null;
        _explosionTop = null;
      });
    });
  }

  void _gameOver() {
    setState(() => _isGameOver = true);
    Future.delayed(Duration(seconds: 2), () {
      if (mounted) Navigator.of(context).pop();
    });
  }

  void _reachPlanet() {
    setState(() {
      _reachedPlanet = true;
      _spaceObjects.clear();
      occupiedLanes.clear();
      _planetController.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isGameOver) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Transform.rotate(
            angle: 1.5708,
            child: Text('GAME OVER', style: TextStyle(color: Colors.red, fontSize: 48, fontWeight: FontWeight.bold)),
          ),
        ),
      );
    }

    final orientation = MediaQuery.of(context).orientation;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    const backgroundWidth = 1550.0;
    const backgroundHeight = 1296.0;

    final double rocketWidth = 100;
    final double rocketHeight = 100;
    final double maxY = (screenHeight - rocketHeight) / 2;

    final double rocketLeft = 40;
    final double rocketTop = (screenHeight - rocketHeight) / 2 + (rocketY * maxY);

    const double healthBarHeight = 30.0;
    const double healthBarMaxWidth = 200.0;
    final double healthBarWidth = (health / 100.0) * healthBarMaxWidth;

    final double healthBarLeft = screenWidth - 140;
    final double healthBarTop = 640;

    const double timerBarHeight = 20.0;
    const double timerBarMaxWidth = 300.0;
    final double timerBarWidth = (_progressValue / _maxProgressTime) * timerBarMaxWidth;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned(
            left: _planetCentered ? 0 : backgroundLeftOffset - (_backgroundController.value * backgroundWidth),
            top: backgroundTopOffset,
            child: Transform.rotate(
              angle: orientation == Orientation.landscape ? 1.5708 : 0,
              child: Image.asset('assets/background2.png', width: backgroundWidth, height: backgroundHeight, fit: BoxFit.cover),
            ),
          ),
          if (!_planetCentered)
            Positioned(
              left: backgroundLeftOffset - (_backgroundController.value * backgroundWidth) + backgroundWidth,
              top: backgroundTopOffset,
              child: Transform.rotate(
                angle: orientation == Orientation.landscape ? 1.5708 : 0,
                child: Image.asset('assets/background2.png', width: backgroundWidth, height: backgroundHeight, fit: BoxFit.cover),
              ),
            ),
          Positioned(
            left: 50,
            top: 35,
            child: Transform.rotate(
              angle: 6.2832,
              child: Container(
                width: timerBarMaxWidth,
                height: timerBarHeight,
                decoration: BoxDecoration(border: Border.all(color: Colors.white, width: 2)),
                child: Stack(
                  children: [
                    Container(width: timerBarWidth, height: timerBarHeight, color: Colors.blue),
                    Positioned(
                      right: 0,
                      child: Container(
                        width: 30,
                        height: timerBarHeight,
                        color: Colors.red,
                        child: Center(
                          child: Text('${_progressValue.toInt()}s',
                              style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (!_reachedPlanet)
            ..._spaceObjects.map((obj) {
              final double objLeft = backgroundLeftOffset + (obj['x'] * backgroundWidth);
              final double objTop = (screenHeight - 80) / 2 + (obj['y'] * (screenHeight / 2 - 40));
              return Positioned(
                left: objLeft,
                top: objTop,
                child: Transform.rotate(
                  angle: orientation == Orientation.landscape ? 1.5708 : 0,
                  child: Image.asset(
                    obj['imagePath'],
                    width: obj['imagePath'] == 'assets/bluerocket.png' ? 100 : 80,
                    height: obj['imagePath'] == 'assets/bluerocket.png' ? 100 : 80,
                    fit: obj['imagePath'] == 'assets/bluerocket.png' ? BoxFit.contain : BoxFit.cover,
                  ),
                ),
              );
            }).toList(),
          Positioned(
            left: rocketLeft,
            top: rocketTop,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onPanUpdate: (details) => _moveRocket(details, orientation),
              child: Container(
                width: 150,
                height: 150,
                child: Center(child: Image.asset('assets/rocketmain.gif', width: 100, height: 100)),
              ),
            ),
          ),
          if (_isExploding && _explosionLeft != null && _explosionTop != null)
            Positioned(
              left: _explosionLeft,
              top: _explosionTop,
              child: Transform.rotate(
                angle: orientation == Orientation.landscape ? 1.5708 : 0,
                child: Image.asset('assets/explosion.png', width: 100, height: 100, fit: BoxFit.contain),
              ),
            ),
          if (_reachedPlanet)
            AnimatedBuilder(
              animation: _planetController,
              builder: (context, child) {
                final double planetLeft =
                    screenWidth * _planetAnimation.value + (screenWidth - widget.planetWidth) / 2 * (1 - _planetAnimation.value);
                return Positioned(
                  left: planetLeft,
                  top: (screenHeight - widget.planetHeight) / 2,
                  child: Transform.rotate(
                    angle: orientation == Orientation.landscape ? 1.5708 : 0,
                    child: Image.asset(widget.selectedPlanetAsset, width: widget.planetWidth, height: widget.planetHeight),
                  ),
                );
              },
            ),
          if (_planetCentered)
            Positioned(
              left: screenWidth / 2 - 100,
              top: screenHeight / 2 + widget.planetHeight / 2 + 20,
              child: Transform.rotate(
                angle: orientation == Orientation.landscape ? 1.5708 : 0,
                child: Text('Welcome to ${getPlanetName()}',
                    style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
              ),
            ),
          Positioned(
            left: healthBarLeft,
            top: healthBarTop,
            child: Transform.rotate(
              angle: orientation == Orientation.landscape ? 3.1416 : 1.5708,
              child: Container(
                width: healthBarMaxWidth + healthBarHeight,
                height: healthBarHeight,
                child: Row(
                  children: [
                    Container(
                      width: healthBarHeight,
                      height: healthBarHeight,
                      decoration: BoxDecoration(shape: BoxShape.circle, color: Color.fromARGB(255, 192, 13, 0)),
                      child: Center(child: Icon(Icons.add, color: Colors.white, size: 20)),
                    ),
                    Container(width: healthBarWidth, height: healthBarHeight, color: Color.fromARGB(255, 0, 255, 8)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Extension for String capitalization
extension StringExtension on String {
  String capitalize() => "${this[0].toUpperCase()}${substring(1)}";
}