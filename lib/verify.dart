import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VerifyScreen extends StatefulWidget {
  final String email;
  const VerifyScreen({Key? key, required this.email}) : super(key: key);

  @override
  _VerifyScreenState createState() => _VerifyScreenState();
}

class _VerifyScreenState extends State<VerifyScreen> {
  final TextEditingController _codeController = TextEditingController();
  final FocusNode _codeFocusNode = FocusNode();
  bool _isLoading = false;
  final storage = const FlutterSecureStorage();

  Future<void> _verifyEmail() async {
    if (_codeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the verification code')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Verify email
      final verifyUrl = Uri.parse('https://backend-lesu72cxy-g4s-projects-7b5d827c.vercel.app/verify');
      final verifyResponse = await http.post(
        verifyUrl,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': widget.email,
          'code': _codeController.text.trim(),
        }),
      );

      final verifyResponseData = jsonDecode(verifyResponse.body);
      if (verifyResponse.statusCode == 201) {
        // Store JWT token
        await storage.write(key: 'jwt_token', value: verifyResponseData['token']);

        // Retrieve stored avatar and save to backend
        final prefs = await SharedPreferences.getInstance();
        final selectedAvatar = prefs.getString('selected_avatar');
        if (selectedAvatar != null) {
          final avatarUrl = Uri.parse('https://backend-lesu72cxy-g4s-projects-7b5d827c.vercel.app/update-avatar');
          final avatarResponse = await http.post(
            avatarUrl,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer ${verifyResponseData['token']}',
            },
            body: jsonEncode({
              'email': widget.email,
              'avatar': selectedAvatar,
            }),
          );

          final avatarResponseData = jsonDecode(avatarResponse.body);
          if (avatarResponse.statusCode == 200) {
            print('Avatar saved: ${avatarResponseData['message']}');
            // Clear stored avatar after saving
            await prefs.remove('selected_avatar');
          } else {
            print('Avatar save failed: ${avatarResponseData['error']}');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error saving avatar: ${avatarResponseData['error']}')),
            );
          }
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Email verified successfully!')),
        );
        Navigator.pushReplacementNamed(context, '/main');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${verifyResponseData['error']}')),
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
                'Verify Email',
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
              width: 150 * widthScale,
              height: 22 * heightScale,
              child: const Text(
                'Verification Code',
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
                controller: _codeController,
                focusNode: _codeFocusNode,
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
            top: 220 * heightScale,
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
            top: 215 * heightScale,
            child: SizedBox(
              width: 61 * widthScale,
              height: 50 * heightScale,
              child: TextButton(
                onPressed: _isLoading ? null : _verifyEmail,
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
                          'Verify',
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
        ],
      ),
    );
  }

  @override
  void dispose() {
    _codeController.dispose();
    _codeFocusNode.dispose();
    super.dispose();
  }
}