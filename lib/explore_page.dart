import 'package:flutter/material.dart';
import 'home_page.dart'; // Import for InterestCard

class ExplorePage extends StatelessWidget {
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
                "Explore",
                style: TextStyle(
                  fontFamily: 'Rubik',
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF251504),
                ),
              ),
              SizedBox(height: 20),
              TextField(
                decoration: InputDecoration(
                  hintText: "Search topics...",
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              SizedBox(height: 20),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  children: [
                    InterestCard(
                      title: "Nature",
                      color: Color(0xFFE6FFA2),
                      borderColor: Color(0xFFCBEA7B),
                      image: 'assets/image3.png',
                    ),
                    InterestCard(
                      title: "English",
                      color: Color(0xFFFCE2B9),
                      borderColor: Color(0xFFEDD0A2),
                      image: 'assets/image.png',
                    ),
                    InterestCard(
                      title: "Science",
                      color: Color(0xFFCBECFF),
                      borderColor: Color(0xFFB9D3E3),
                      image: 'assets/science1.png',
                    ),
                    InterestCard(
                      title: "History",
                      color: Color(0xFFFFD7D7),
                      borderColor: Color(0xFFE8B8B8),
                      image: 'assets/history_image.png',
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