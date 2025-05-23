import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;

const kPrimaryColor = Color(0xFFFFC045);
const kSecondaryColor = Color(0xFFF3561A);
const kBackgroundColor = Color(0xFFF7F1E5);
const kCardColor = Colors.white;
const kTextColor = Color(0xFF251504);
const kErrorColor = Color(0xFFD9534F);
const kSuccessColor = Color(0xFF5CB85C);
const kFontFamily = 'Rubik';

class GameScreen extends StatefulWidget {
  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with SingleTickerProviderStateMixin {
  File? _image;
  String _result = '';
  bool _isLoading = false;
  String? _currentLetterKey;
  String? _currentLetterValue;
  bool _showFeedback = false;
  bool _isCorrect = false;
  final picker = ImagePicker();
  final Random _random = Random();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final Map<String, String> amharicLetters = {
    'ha': 'ሀ', 'la': 'ለ', 'ha2': 'ሐ', 'ma': 'መ', 'sa': 'ሠ', 'ra': 'ረ', 'sa2': 'ሰ',
    'sha': 'ሸ', 'qa': 'ቀ', 'ba': 'በ', 'ta': 'ተ', 'cha': 'ቸ', 'kha': 'ኀ', 'na': 'ነ',
    'nya': 'ኘ', 'a': 'አ', 'ka': 'ከ', 'kha2': 'ኸ', 'wa': 'ወ', 'aa': 'ዐ', 'za': 'ዘ',
    'zha': 'ዠ', 'ya': 'የ', 'da': 'ደ', 'ja': 'ጀ', 'ga': 'ገ', 'ta2': 'ጠ', 'cha2': 'ጨ',
    'pa': 'ጰ', 'tsa': 'ጸ', 'tsa2': 'ፀ', 'fa': 'ፈ', 'pa2': 'ፐ',
  };

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _selectRandomLetter();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _selectRandomLetter() {
    final keys = amharicLetters.keys.toList();
    setState(() {
      _currentLetterKey = keys[_random.nextInt(keys.length)];
      _currentLetterValue = amharicLetters[_currentLetterKey];
      _image = null;
      _result = '';
      _showFeedback = false;
      _isCorrect = false;
      _animationController.reset();
    });
  }

  Future getImage() async {
    final pickedFile = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
      preferredCameraDevice: CameraDevice.front,
    );

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
        _result = '';
        _showFeedback = false;
        _animationController.reset();
      }
    });
  }

  Future detectGesture() async {
    if (_image == null || _currentLetterKey == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please take a picture first!')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _showFeedback = false;
      _animationController.reset();
    });

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('https://heran23.pythonanywhere.com/detect'),
      );

      var fileStream = http.ByteStream(_image!.openRead());
      var length = await _image!.length();
      var multipartFile = http.MultipartFile(
        'file',
        fileStream,
        length,
        filename: _image!.path.split('/').last,
      );
      request.files.add(multipartFile);

      var response = await request.send();
      var responseString = await response.stream.bytesToString();

      bool correct = false;
      String resultMessage = "Could not verify gesture.";

      if (response.statusCode == 200) {
        try {
          final jsonResponse = json.decode(responseString);
          final predictions = jsonResponse['predictions'];
          if (predictions != null && predictions.isNotEmpty) {
            String detectedClass = predictions[0]['class'].toLowerCase();
            correct = detectedClass == _currentLetterKey;
            resultMessage = correct ? "Correct!" : "Incorrect, try again!";
          } else {
            resultMessage = "No prediction received from server.";
          }
        } catch (e) {
          resultMessage = "Error processing server response.";
          correct = false;
        }
      } else {
        resultMessage = "Server Error: ${response.statusCode}";
        correct = false;
      }

      setState(() {
        _isLoading = false;
        _showFeedback = true;
        _isCorrect = correct;
        _result = resultMessage;
      });

      _animationController.forward();
    } catch (e) {
      setState(() {
        _result = "An error occurred. Check connection.";
        _isLoading = false;
        _showFeedback = true;
        _isCorrect = false;
        _animationController.forward();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        elevation: 0,
        title: Text(
          'Amharic Sign Language',
          style: TextStyle(
            fontFamily: kFontFamily,
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: kTextColor,
          ),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [kPrimaryColor, kSecondaryColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Letter Card
                  _buildLetterCard(size),
                  SizedBox(height: 16),
                  // Example Sign Card
                  _buildExampleSignCard(size),
                  SizedBox(height: 16),
                  // User Attempt Card
                  _buildUserAttemptCard(size),
                  SizedBox(height: 16),
                  // Action Buttons
                  _buildActionButtons(),
                  SizedBox(height: 16),
                  // Feedback Card
                  _buildFeedbackCard(),
                ],
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 100,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [kPrimaryColor.withOpacity(0.2), Colors.transparent],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLetterCard(Size size) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kCardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: kTextColor.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
        border: Border.all(color: kPrimaryColor.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            'Sign This Letter',
            style: TextStyle(
              fontFamily: kFontFamily,
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: kTextColor.withOpacity(0.8),
            ),
          ),
          SizedBox(height: 12),
          Text(
            _currentLetterValue ?? '?',
            style: TextStyle(
              fontFamily: kFontFamily,
              fontSize: 72,
              fontWeight: FontWeight.bold,
              color: kSecondaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExampleSignCard(Size size) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      width: double.infinity,
      decoration: BoxDecoration(
        color: kCardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: kTextColor.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            child: Container(
              height: 200, // Increased from 180 to accommodate full image
              width: double.infinity,
              child: Builder(
                builder: (context) {
                  String imagePath = 'assets/${_currentLetterValue ?? 'placeholder'}.jpg';
                  return Image.asset(
                    imagePath,
                    fit: BoxFit.contain, // Changed from cover to contain
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: kBackgroundColor,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.image_not_supported, color: kErrorColor, size: 40),
                              SizedBox(height: 8),
                              Text(
                                'Image not found',
                                style: TextStyle(
                                  fontFamily: kFontFamily,
                                  fontSize: 16,
                                  color: kErrorColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Example Sign',
              style: TextStyle(
                fontFamily: kFontFamily,
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: kTextColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserAttemptCard(Size size) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kCardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: kTextColor.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Your Attempt',
            style: TextStyle(
              fontFamily: kFontFamily,
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: kTextColor.withOpacity(0.8),
            ),
          ),
          SizedBox(height: 12),
          Container(
            height: size.width * 0.65,
            width: size.width * 0.65,
            decoration: BoxDecoration(
              color: kBackgroundColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: kTextColor.withOpacity(0.05),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: _image == null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.camera_alt_outlined,
                          size: 50,
                          color: kTextColor.withOpacity(0.4),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Take a photo',
                          style: TextStyle(
                            fontFamily: kFontFamily,
                            fontSize: 16,
                            color: kTextColor.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.file(
                      _image!,
                      fit: BoxFit.contain, // Changed from cover to contain
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildActionButton(
          icon: Icons.camera_alt,
          text: 'Take Photo',
          onTap: _isLoading ? null : getImage,
          gradientColors: [kPrimaryColor, kSecondaryColor],
        ),
        SizedBox(width: 16),
        _buildActionButton(
          icon: Icons.check_circle,
          text: 'Check',
          onTap: _image == null || _isLoading ? null : detectGesture,
          gradientColors: _image == null || _isLoading
              ? [Colors.grey[400]!, Colors.grey[600]!]
              : [kSecondaryColor, kPrimaryColor],
          isLoading: _isLoading,
        ),
        SizedBox(width: 16),
        _buildActionButton(
          icon: Icons.arrow_forward,
          text: 'Next',
          onTap: _isLoading ? null : _selectRandomLetter,
          gradientColors: [kPrimaryColor.withOpacity(0.7), kSecondaryColor.withOpacity(0.7)],
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String text,
    required VoidCallback? onTap,
    required List<Color> gradientColors,
    bool isLoading = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: kTextColor.withOpacity(0.2),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            isLoading
                ? SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Icon(icon, color: Colors.white, size: 30),
            SizedBox(height: 8),
            Text(
              text,
              style: TextStyle(
                fontFamily: kFontFamily,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedbackCard() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: _showFeedback
          ? AnimatedContainer(
              duration: Duration(milliseconds: 300),
              width: double.infinity,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: kCardColor,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: kTextColor.withOpacity(0.1),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
                border: Border.all(
                  color: _isCorrect ? kSuccessColor.withOpacity(0.3) : kErrorColor.withOpacity(0.3),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    _isCorrect ? 'assets/correct.gif' : 'assets/wrong.gif',
                    height: 60,
                    width: 60,
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      _result,
                      style: TextStyle(
                        fontFamily: kFontFamily,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: _isCorrect ? kSuccessColor : kErrorColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            )
          : SizedBox(height: 100),
    );
  }
}