import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ResetPasswordScreen extends StatefulWidget {
  final String email;
  const ResetPasswordScreen({Key? key, required this.email}) : super(key: key);

  @override
  _ResetPasswordScreenState createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final FocusNode _codeFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  bool _isLoading = false;

  Future<void> _resetPassword() async {
    if (_codeController.text.isEmpty || _newPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final url = Uri.parse('https://backend-q7hugy6cd-g4s-projects-7b5d827c.vercel.app/reset-password');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': widget.email,
          'code': _codeController.text.trim(),
          'newPassword': _newPasswordController.text.trim(),
        }),
      );

      final responseData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        print('Password reset: ${responseData['message']}');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password reset successfully!')),
        );
        Navigator.pushNamed(context, '/login');
      } else {
        print('Reset failed: ${responseData['error']}');
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
                'Reset Password',
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
                'Reset Code',
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
            left: 31 * widthScale,
            top: 206 * heightScale,
            child: SizedBox(
              width: 130 * widthScale,
              height: 22 * heightScale,
              child: const Text(
                'New Password',
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
                controller: _newPasswordController,
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
            top: 280 * heightScale,
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
            top: 275 * heightScale,
            child: SizedBox(
              width: 61 * widthScale,
              height: 50 * heightScale,
              child: TextButton(
                onPressed: _isLoading ? null : _resetPassword,
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
                          'Reset',
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
    _newPasswordController.dispose();
    _codeFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }
}