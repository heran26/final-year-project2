import 'package:flutter/material.dart';
import 'home_page.dart'; // Import for LessonCard

class LibraryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF7F1E5),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Library",
                style: TextStyle(
                  fontFamily: 'Rubik',
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF251504),
                ),
              ),
              SizedBox(height: 20),
              Expanded(
                child: ListView(
                  children: [
                    LessonCard(
                      title: "Saved Lesson 1",
                      description: "Long established fact that a reader.",
                      progress: "68%",
                      image: 'assets/lesson_image.png',
                    ),
                    SizedBox(height: 20),
                    LessonCard(
                      title: "Saved Lesson 2",
                      description: "Contrary to popular belief.",
                      progress: "45%",
                      image: 'assets/lesson_image2.png',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}