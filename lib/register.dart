import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _schoolController = TextEditingController();
  final TextEditingController _dateOfBirthController = TextEditingController();
  final TextEditingController _gradeController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final FocusNode _nameFocusNode = FocusNode();
  final FocusNode _schoolFocusNode = FocusNode();
  final FocusNode _dateOfBirthFocusNode = FocusNode();
  final FocusNode _gradeFocusNode = FocusNode();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  String? _selectedGender = 'Female';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeFields();
  }

  void _initializeFields() {
    _nameController.text = 'Jitu Tesfaye';
    _schoolController.text = 'Cruise School';
    _dateOfBirthController.text = '12/12/12';
    _gradeController.text = '5';

    _nameFocusNode.addListener(() {
      if (_nameFocusNode.hasFocus && _nameController.text == 'Jitu Tesfaye') {
        _nameController.clear();
      }
    });
    _schoolFocusNode.addListener(() {
      if (_schoolFocusNode.hasFocus && _schoolController.text == 'Cruise School') {
        _schoolController.clear();
      }
    });
    _dateOfBirthFocusNode.addListener(() {
      if (_dateOfBirthFocusNode.hasFocus && _dateOfBirthController.text == '12/12/12') {
        _dateOfBirthController.clear();
      }
    });
    _gradeFocusNode.addListener(() {
      if (_gradeFocusNode.hasFocus && _gradeController.text == '5') {
        _gradeController.clear();
      }
    });
    _emailFocusNode.addListener(() {
      if (_emailFocusNode.hasFocus && _emailController.text.isEmpty) {
        _emailController.clear();
      }
    });
    _passwordFocusNode.addListener(() {
      if (_passwordFocusNode.hasFocus && _passwordController.text.isEmpty) {
        _passwordController.clear();
      }
    });
  }

  Future<void> _saveToBackend() async {
    if (_nameController.text.isEmpty ||
        _schoolController.text.isEmpty ||
        _dateOfBirthController.text.isEmpty ||
        _gradeController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final url = Uri.parse('https://backend-lesu72cxy-g4s-projects-7b5d827c.vercel.app/register');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': _nameController.text.trim(),
          'gender': _selectedGender,
          'school': _schoolController.text.trim(),
          'dateOfBirth': _dateOfBirthController.text.trim(),
          'grade': _gradeController.text.trim(),
          'email': _emailController.text.trim(),
          'password': _passwordController.text.trim(),
        }),
      );

      final responseData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        print('Registration successful: ${responseData['message']}');
        // Prepare registration data to pass to avatar picker
        final registrationData = {
          'name': _nameController.text.trim(),
          'gender': _selectedGender,
          'school': _schoolController.text.trim(),
          'dateOfBirth': _dateOfBirthController.text.trim(),
          'grade': _gradeController.text.trim(),
          'email': _emailController.text.trim(),
          'password': _passwordController.text.trim(),
        };
        // Navigate to avatar picker based on gender
        if (_selectedGender == 'Female') {
          Navigator.pushNamed(
            context,
            '/avatar_girl',
            arguments: registrationData,
          );
        } else if (_selectedGender == 'Male') {
          Navigator.pushNamed(
            context,
            '/avatar_boy',
            arguments: registrationData,
          );
        } else {
          // For 'Other', default to female avatars
          Navigator.pushNamed(
            context,
            '/avatar_girl',
            arguments: registrationData,
          );
        }
      } else {
        print('Registration failed: ${responseData['error']}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${responseData['error']}')),
        );
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2012, 12, 12),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _dateOfBirthController.text =
            "${picked.day}/${picked.month}/${picked.year % 100}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    const designWidth = 360.0;
    const designHeight = 640.0;
    final widthScale = screenWidth / designWidth;
    final heightScale = screenHeight / designHeight;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: screenWidth,
            height: screenHeight,
            color: const Color(0xFFFFFFFF),
          ),
          Positioned(
            left: 0 * widthScale,
            top: 0 * heightScale,
            child: Container(
              width: 360 * widthScale,
              height: 56 * heightScale,
              decoration: const BoxDecoration(
                color: Color(0xFFFFFFFF),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFFEEEEEE),
                    offset: Offset(0, 4),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 16 * widthScale,
            top: 16 * heightScale,
            child: IconButton(
              icon: const Icon(
                Icons.chevron_left,
                size: 24,
                color: Color.fromRGBO(0, 0, 0, 0.54),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
              padding: EdgeInsets.zero,
              constraints: BoxConstraints(
                minWidth: 24 * widthScale,
                minHeight: 24 * heightScale,
              ),
            ),
          ),
          Positioned(
            left: 16 * widthScale,
            top: 80 * heightScale,
            child: SizedBox(
              width: 233 * widthScale,
              height: 46 * heightScale,
              child: const Text(
                'Register',
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w700,
                  color: Color.fromRGBO(0, 0, 0, 0.84),
                ),
              ),
            ),
          ),
          Positioned(
            left: 29 * widthScale,
            top: 141 * heightScale,
            child: SizedBox(
              width: 47 * widthScale,
              height: 22 * heightScale,
              child: const Text(
                'Name',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF000000),
                ),
              ),
            ),
          ),
          Positioned(
            left: 16 * widthScale,
            top: 160 * heightScale,
            child: Container(
              width: 290 * widthScale,
              height: 40 * heightScale,
              decoration: BoxDecoration(
                color: const Color(0xFFEEEEEE),
                borderRadius: BorderRadius.circular(25 * widthScale),
              ),
            ),
          ),
          Positioned(
            left: 30 * widthScale,
            top: 160 * heightScale,
            child: SizedBox(
              width: 260 * widthScale,
              height: 40 * heightScale,
              child: TextField(
                controller: _nameController,
                focusNode: _nameFocusNode,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                ),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Color.fromRGBO(0, 0, 0, 0.35),
                ),
              ),
            ),
          ),
          Positioned(
            left: 29 * widthScale,
            top: 203 * heightScale,
            child: SizedBox(
              width: 59 * widthScale,
              height: 22 * heightScale,
              child: const Text(
                'Gender',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF000000),
                ),
              ),
            ),
          ),
          Positioned(
            left: 16 * widthScale,
            top: 222 * heightScale,
            child: Container(
              width: 290 * widthScale,
              height: 40 * heightScale,
              decoration: BoxDecoration(
                color: const Color(0xFFEEEEEE),
                borderRadius: BorderRadius.circular(25 * widthScale),
              ),
            ),
          ),
          Positioned(
            left: 26 * widthScale,
            top: 222 * heightScale,
            child: SizedBox(
              width: 290 * widthScale,
              height: 40 * heightScale,
              child: DropdownButton<String>(
                value: _selectedGender,
                isDense: true,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                underline: const SizedBox(),
                items: <String>['Male', 'Female', 'Other']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      value,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Color.fromRGBO(0, 0, 0, 0.35),
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedGender = newValue;
                  });
                },
              ),
            ),
          ),
          Positioned(
            left: 29 * widthScale,
            top: 265 * heightScale,
            child: SizedBox(
              width: 59 * widthScale,
              height: 22 * heightScale,
              child: const Text(
                'School',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF000000),
                ),
              ),
            ),
          ),
          Positioned(
            left: 16 * widthScale,
            top: 284 * heightScale,
            child: Container(
              width: 290 * widthScale,
              height: 40 * heightScale,
              decoration: BoxDecoration(
                color: const Color(0xFFEEEEEE),
                borderRadius: BorderRadius.circular(25 * widthScale),
              ),
            ),
          ),
          Positioned(
            left: 31 * widthScale,
            top: 284 * heightScale,
            child: SizedBox(
              width: 260 * widthScale,
              height: 40 * heightScale,
              child: TextField(
                controller: _schoolController,
                focusNode: _schoolFocusNode,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                ),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Color.fromRGBO(0, 0, 0, 0.35),
                ),
              ),
            ),
          ),
          Positioned(
            left: 29 * widthScale,
            top: 327 * heightScale,
            child: SizedBox(
              width: 102 * widthScale,
              height: 22 * heightScale,
              child: const Text(
                'Date of Birth',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF000000),
                ),
              ),
            ),
          ),
          Positioned(
            left: 16 * widthScale,
            top: 346 * heightScale,
            child: Container(
              width: 135 * widthScale,
              height: 40 * heightScale,
              decoration: BoxDecoration(
                color: const Color(0xFFEEEEEE),
                borderRadius: BorderRadius.circular(25 * widthScale),
              ),
            ),
          ),
          Positioned(
            left: 31 * widthScale,
            top: 346 * heightScale,
            child: SizedBox(
              width: 105 * widthScale,
              height: 40 * heightScale,
              child: TextField(
                controller: _dateOfBirthController,
                focusNode: _dateOfBirthFocusNode,
                readOnly: true,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                ),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Color.fromRGBO(0, 0, 0, 0.35),
                ),
                onTap: () => _selectDate(context),
              ),
            ),
          ),
          Positioned(
            left: 177 * widthScale,
            top: 327 * heightScale,
            child: SizedBox(
              width: 47 * widthScale,
              height: 22 * heightScale,
              child: const Text(
                'Grade',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF000000),
                ),
              ),
            ),
          ),
          Positioned(
            left: 166 * widthScale,
            top: 346 * heightScale,
            child: Container(
              width: 140 * widthScale,
              height: 40 * heightScale,
              decoration: BoxDecoration(
                color: const Color(0xFFEEEEEE),
                borderRadius: BorderRadius.circular(25 * widthScale),
              ),
            ),
          ),
          Positioned(
            left: 176 * widthScale,
            top: 346 * heightScale,
            child: SizedBox(
              width: 110 * widthScale,
              height: 40 * heightScale,
              child: TextField(
                controller: _gradeController,
                focusNode: _gradeFocusNode,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                ),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Color.fromRGBO(0, 0, 0, 0.35),
                ),
              ),
            ),
          ),
          Positioned(
            left: 28 * widthScale,
            top: 392 * heightScale,
            child: SizedBox(
              width: 103 * widthScale,
              height: 22 * heightScale,
              child: const Text(
                'Email',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF000000),
                ),
              ),
            ),
          ),
          Positioned(
            left: 17 * widthScale,
            top: 415 * heightScale,
            child: Container(
              width: 290 * widthScale,
              height: 40 * heightScale,
              decoration: BoxDecoration(
                color: const Color(0xFFEEEEEE),
                borderRadius: BorderRadius.circular(25 * widthScale),
              ),
            ),
          ),
          Positioned(
            left: 16 * widthScale,
            top: 415 * heightScale,
            child: SizedBox(
              width: 260 * widthScale,
              height: 40 * heightScale,
              child: TextField(
                controller: _emailController,
                focusNode: _emailFocusNode,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                ),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Color.fromRGBO(0, 0, 0, 0.35),
                ),
              ),
            ),
          ),
          Positioned(
            left: 31 * widthScale,
            top: 460 * heightScale,
            child: SizedBox(
              width: 74 * widthScale,
              height: 22 * heightScale,
              child: const Text(
                'Password',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF000000),
                ),
              ),
            ),
          ),
          Positioned(
            left: 17 * widthScale,
            top: 483 * heightScale,
            child: Container(
              width: 290 * widthScale,
              height: 40 * heightScale,
              decoration: BoxDecoration(
                color: const Color(0xFFEEEEEE),
                borderRadius: BorderRadius.circular(25 * widthScale),
              ),
            ),
          ),
          Positioned(
            left: 16 * widthScale,
            top: 483 * heightScale,
            child: SizedBox(
              width: 260 * widthScale,
              height: 40 * heightScale,
              child: TextField(
                controller: _passwordController,
                focusNode: _passwordFocusNode,
                obscureText: true,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                ),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Color.fromRGBO(0, 0, 0, 0.35),
                ),
              ),
            ),
          ),
          Positioned(
            left: 112.5 * widthScale,
            top: 552 * heightScale,
            child: Container(
              width: 135 * widthScale,
              height: 40 * heightScale,
              decoration: BoxDecoration(
                color: const Color(0xFFFFD18B),
                borderRadius: BorderRadius.circular(25 * widthScale),
              ),
            ),
          ),
          Positioned(
            left: 150 * widthScale,
            top: 547 * heightScale,
            child: SizedBox(
              width: 61 * widthScale,
              height: 50 * heightScale,
              child: TextButton(
                onPressed: _isLoading ? null : _saveToBackend,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.transparent,
                  overlayColor: Colors.transparent,
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.black)
                    : const Center(
                        child: Text(
                          'Register',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF000000),
                          ),
                        ),
                      ),
              ),
            ),
          ),
          Positioned(
            left: -11 * widthScale,
            top: 551 * heightScale,
            child: Image.asset(
              'assets/girl-removebg-preview.png',
              width: 131 * widthScale,
              height: 98 * heightScale,
            ),
          ),
          Positioned(
            left: 250 * widthScale,
            top: 51 * heightScale,
            child: Image.asset(
              'assets/boy.png',
              width: 131 * widthScale,
              height: 98 * heightScale,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _schoolController.dispose();
    _dateOfBirthController.dispose();
    _gradeController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nameFocusNode.dispose();
    _schoolFocusNode.dispose();
    _dateOfBirthFocusNode.dispose();
    _gradeFocusNode.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }
}