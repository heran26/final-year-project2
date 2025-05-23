import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  bool _isLoading = false;
  final storage = const FlutterSecureStorage();

  Future<void> _login() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final url = Uri.parse('https://backend-lesu72cxy-g4s-projects-7b5d827c.vercel.app/login');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': _emailController.text.trim(),
          'password': _passwordController.text.trim(),
        }),
      );

      final responseData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        await storage.write(key: 'jwt_token', value: responseData['token']);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login successful!')),
        );
        Navigator.pushReplacementNamed(context, '/main');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${responseData['error']}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _forgotPassword() async {
    if (_emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your email')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final url = Uri.parse('https://backend-lesu72cxy-g4s-projects-7b5d827c.vercel.app/forgot-password');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': _emailController.text.trim(),
        }),
      );

      final responseData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password reset code sent to your email')),
        );
        Navigator.pushNamed(context, '/reset-password', arguments: _emailController.text.trim());
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${responseData['error']}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
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
                'Login',
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
            left: 16 * widthScale,
            top: 160 * heightScale,
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
            top: 206 * heightScale,
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
            top: 225 * heightScale,
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
            top: 225 * heightScale,
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
            top: 294 * heightScale,
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
            top: 289 * heightScale,
            child: SizedBox(
              width: 61 * widthScale,
              height: 50 * heightScale,
              child: TextButton(
                onPressed: _isLoading ? null : _login,
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
                          'Login',
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
            left: 112.5 * widthScale,
            top: 340 * heightScale,
            child: GestureDetector(
              onTap: _forgotPassword,
              child: const Text(
                'Forgot Password?',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF2CA2B0),
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
          Positioned(
            left: -11 * widthScale,
            top: 293 * heightScale,
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
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }
}