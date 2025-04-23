import 'package:flutter/material.dart';

class AvatarPickerScreen extends StatefulWidget {
  const AvatarPickerScreen({super.key});

  @override
  State<AvatarPickerScreen> createState() => _AvatarPickerScreenState();
}

class _AvatarPickerScreenState extends State<AvatarPickerScreen> {
  String? _selectedAvatar;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: 360,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Color.fromARGB(255, 17, 208, 87).withOpacity(0.2),
                    spreadRadius: 0,
                    blurRadius: 4,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.only(left: 16, top: 16),
                child: BackButton(
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(left: 68, top: 14),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Pick an Avatar',
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 34,
                    fontWeight: FontWeight.w700,
                    color: Color.fromRGBO(0, 0, 0, 0.84),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: GridView.count(
                  crossAxisCount: 3,
                  crossAxisSpacing: 7,
                  mainAxisSpacing: 14,
                  padding: const EdgeInsets.only(top: 24, bottom: 24),
                  children: [
                    _buildAvatarContainer('assets/avatari.png', 120, 127),
                    _buildAvatarContainer('assets/avatarii.png', 170, 123),
                    _buildAvatarContainer('assets/avatariii.png', 152, 134),
                    _buildAvatarContainer('assets/avatariv.png', 160, 136),
                    _buildAvatarContainer('assets/avatarv.png', 191, 123),
                    _buildAvatarContainer('assets/avatarvi.png', 152, 137),
                    _buildAvatarContainer('assets/avatarvii.png', 187, 136),
                    _buildAvatarContainer('assets/avatarviii.png', 162, 129),
                    _buildAvatarContainer('assets/avatarviiii.png', 152, 128),
                    _buildAvatarContainer('assets/avatar102.png', 154, 127),
                    _buildAvatarContainer('assets/avatar112.png', 166, 116),
                    _buildAvatarContainer('assets/avatar122.png', 133, 141),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 12, bottom: 12),
              child: Align(
                alignment: Alignment.bottomRight,
                child: ElevatedButton(
                  onPressed: _selectedAvatar != null
                      ? () {
                          Navigator.pushNamed(context, '/main');
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2DE548),
                    foregroundColor: const Color(0xFF0B521E),
                    minimumSize: const Size(72, 44),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: const BorderSide(
                        color: Color(0xFF0B521E),
                        width: 5,
                      ),
                    ),
                    elevation: 4,
                  ),
                  child: Image.asset(
                    'assets/tick.png',
                    width: 36,
                    height: 36,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarContainer(String imagePath, double width, double height) {
    bool isSelected = _selectedAvatar == imagePath;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedAvatar = imagePath;
        });
      },
      child: Container(
        width: 110,
        height: 106,
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 109, 120, 244),
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.black,
            width: 5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 0,
              blurRadius: 4,
              offset: const Offset(0, 4),
            ),
            if (isSelected)
              BoxShadow(
                color:  Colors.yellow.withOpacity(0.7),
                spreadRadius: 5,
                blurRadius: 8,
              ),
          ],
        ),
        child: Center(
          child: Image.asset(
            imagePath,
            width: width * 0.8,
            height: height * 0.8,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}