import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class BookConfig {
  final String bookId;
  final String title;
  final String description;
  final String coverImage;
  final List<String> pageImageUrls;
  final List<String> audioUrls;
  final Map<int, String> pageTexts;
  final String backgroundImageUrl;
  final String category;
  final String module;

  BookConfig({
    required this.bookId,
    required this.title,
    required this.description,
    required this.coverImage,
    required this.pageImageUrls,
    required this.audioUrls,
    required this.pageTexts,
    required this.backgroundImageUrl,
    this.category = 'general',
    this.module = 'new',
  });
}

// List of hardcoded books
final List<BookConfig> hardcodedBooks = [
  // Book 1: Ants Adventure
  BookConfig(
    bookId: 'book1',
    title: 'Ants Adventure',
    description: 'Learn about ants and their world',
    coverImage: 'https://nqyegstlgecsutcsmtdx.supabase.co/storage/v1/object/public/book1/ant0.png',
    pageImageUrls: [
      'https://nqyegstlgecsutcsmtdx.supabase.co/storage/v1/object/public/book1/ant0.png',
      'https://nqyegstlgecsutcsmtdx.supabase.co/storage/v1/object/public/book1/ant1.png',
      'https://nqyegstlgecsutcsmtdx.supabase.co/storage/v1/object/public/book1/ant2.png',
      'https://nqyegstlgecsutcsmtdx.supabase.co/storage/v1/object/public/book1/ant3.png',
      'https://nqyegstlgecsutcsmtdx.supabase.co/storage/v1/object/public/book1/ant4.png',
      'https://nqyegstlgecsutcsmtdx.supabase.co/storage/v1/object/public/book1/ant5.png',
      'https://nqyegstlgecsutcsmtdx.supabase.co/storage/v1/object/public/book1/ant6.png',
      'https://nqyegstlgecsutcsmtdx.supabase.co/storage/v1/object/public/book1/ant7.png',
      'https://nqyegstlgecsutcsmtdx.supabase.co/storage/v1/object/public/book1/ant8.png',
      'https://nqyegstlgecsutcsmtdx.supabase.co/storage/v1/object/public/book1/ant9.png',
    ],
    audioUrls: [
      'https://nqyegstlgecsutcsmtdx.supabase.co/storage/v1/object/public/book1/ant0_chjjPGn1.ogg',
      'https://nqyegstlgecsutcsmtdx.supabase.co/storage/v1/object/public/book1/ant1_ZXvxEn8F.ogg',
      'https://nqyegstlgecsutcsmtdx.supabase.co/storage/v1/object/public/book1/ant2_zCQSzdf9.ogg',
      'https://nqyegstlgecsutcsmtdx.supabase.co/storage/v1/object/public/book1/ant3_1yrFUnOT.ogg',
      'https://nqyegstlgecsutcsmtdx.supabase.co/storage/v1/object/public/book1/ant4_yYKE4aAB.ogg',
      'https://nqyegstlgecsutcsmtdx.supabase.co/storage/v1/object/public/book1/ant5_rVVJwU2k.ogg',
      'https://nqyegstlgecsutcsmtdx.supabase.co/storage/v1/object/public/book1/ant6_5f8HTRsN.ogg',
      'https://nqyegstlgecsutcsmtdx.supabase.co/storage/v1/object/public/book1/ant7_1PgMHgMc.ogg',
      'https://nqyegstlgecsutcsmtdx.supabase.co/storage/v1/object/public/book1/ant8_rgnSQoam.ogg',
      'https://nqyegstlgecsutcsmtdx.supabase.co/storage/v1/object/public/book1/ant9_4po2kknz.ogg',
    ],
    pageTexts: {
      1: 'ጉንዳኖች ታታሪ ሠራተኞች ናቸው። እነዚህ ነፍሳት ከቡድናቸው ጋር አብረው ይሠራሉ።',
      2: 'ጉንዳኖች ስድስት እግሮች አሏቸው። እነዚህ ነፍሳት ቀጭን ወገብ እና ትልልቅ መንጋጋዎች አሏቸው።',
      3: 'ጉንዳኖች በአንቴናቸው ይሸታሉ፣ ይቀምሳሉ እና ይሰማሉ። እነዚህ ጉንዳኖች ምግብ እንዲያገኙ እና አደጋን እንዲገነዘቡ ይረዷቸዋል።',
      4: 'አብዛኛዎቹ ጉንዳኖች በመሬት ሥር ያሉ ጎጆዎችን ይገነባሉ። እነዚህ ብዙ ክፍሎች እና መንገዶች አሏቸው።',
      5: 'ሠራተኛ ጉንዳኖች የማር ጤዛ እና ሌሎች ምግቦችን ያገኛሉ። እንዲሁም ታዳጊዎችን ይንከባከባሉ።',
      6: 'ሠራተኛ ጉንዳኖች ከራሳቸው ክብደት በላይ ብዙ መሸከም ይችላሉ!',
      7: 'ወታደር ጉንዳኖች ቡድናቸውን ይጠብቃሉ። ንግሥት ጉንዳኖች በሺዎች የሚቆጠሩ እንቁላሎችን ይጥላሉ።',
      8: 'ላርቫዎች ከእንቁላል ይወጣሉ። ብዙ ይበላሉ እና ፑፔ ይሆናሉ።',
      9: 'ፑፔዎች ወደ ጎልማሳ ጉንዳኖች ይለወጣሉ። ጎልማሶቹ ወ revisitዲያውኑ ሥራ ይጀምራሉ!',
    },
    backgroundImageUrl: 'https://nqyegstlgecsutcsmtdx.supabase.co/storage/v1/object/public/book1/table.jpg',
    category: 'science',
    module: 'science',
  ),
  // Book 2: Bees
  BookConfig(
    bookId: 'book2',
    title: 'Bees',
    description: 'Learn about bees and their world',
    coverImage: 'https://nqyegstlgecsutcsmtdx.supabase.co/storage/v1/object/public/book1/bees0.jpg',
    pageImageUrls: [
      'https://nqyegstlgecsutcsmtdx.supabase.co/storage/v1/object/public/book1/bees0.jpg',
      'https://nqyegstlgecsutcsmtdx.supabase.co/storage/v1/object/public/book1/bee1-removebg-preview.png',
      'https://nqyegstlgecsutcsmtdx.supabase.co/storage/v1/object/public/book1/bee2-removebg-preview.png',
      'https://nqyegstlgecsutcsmtdx.supabase.co/storage/v1/object/public/book1/bee3-removebg-preview.png',
      'https://nqyegstlgecsutcsmtdx.supabase.co/storage/v1/object/public/book1/bee4-removebg-preview.png',
      'https://nqyegstlgecsutcsmtdx.supabase.co/storage/v1/object/public/book1/bee5-removebg-preview.png',
      'https://nqyegstlgecsutcsmtdx.supabase.co/storage/v1/object/public/book1/bee6-removebg-preview.png',
      'https://nqyegstlgecsutcsmtdx.supabase.co/storage/v1/object/public/book1/bee7-removebg-preview.png',
      'https://nqyegstlgecsutcsmtdx.supabase.co/storage/v1/object/public/book1/bee8-removebg-preview.png',
      'https://nqyegstlgecsutcsmtdx.supabase.co/storage/v1/object/public/book1/bee9-removebg-preview.png',
    ],
    audioUrls: [
      'https://nqyegstlgecsutcsmtdx.supabase.co/storage/v1/object/public/book1/bee0_audio.ogg',
      'https://nqyegstlgecsutcsmtdx.supabase.co/storage/v1/object/public/book1/bee1_audio.ogg',
      'https://nqyegstlgecsutcsmtdx.supabase.co/storage/v1/object/public/book1/bee2_audio.ogg',
      'https://nqyegstlgecsutcsmtdx.supabase.co/storage/v1/object/public/book1/bee3_audio.ogg',
      'https://nqyegstlgecsutcsmtdx.supabase.co/storage/v1/object/public/book1/bee4_audio.ogg',
      'https://nqyegstlgecsutcsmtdx.supabase.co/storage/v1/object/public/book1/bee5_audio.ogg',
      'https://nqyegstlgecsutcsmtdx.supabase.co/storage/v1/object/public/book1/bee6_audio.ogg',
      'https://nqyegstlgecsutcsmtdx.supabase.co/storage/v1/object/public/book1/bee7_audio.ogg',
      'https://nqyegstlgecsutcsmtdx.supabase.co/storage/v1/object/public/book1/bee8_audio.ogg',
      'https://nqyegstlgecsutcsmtdx.supabase.co/storage/v1/object/public/book1/bee9_audio.ogg',
    ],
    pageTexts: {
      1: 'ንቦች ታታሪ ሠራተኞች ናቸው። እነዚህ ነፍሳት ማር ያመርታሉ።',
      2: 'ንቦች ስድስት እግሮች እና ክንፎች አሏቸው። እነሱ በአበባዎች ላይ ይበራሉ።',
      3: 'ንቦች በአንቴናቸው ይሸታሉ እና ይገናኛሉ። ይህ ምግብ እንዲያገኙ ይረዳቸዋል።',
      4: 'ንቦች ቀፎዎችን ይገነባሉ። እነዚህ ቀፎዎች ብዙ ቀዳዳዎች አሏቸው።',
      5: 'ሠራተኛ ንቦች የአበባ ማር ይሰበስባሉ። እንዲሁም ታዳጊዎችን ይንከባከባሉ።',
      6: 'ንቦች በጭፈራቸው ይገናኛሉ። ይህ ቀፎውን ለመጠበቅ ይረዳል።',
      7: 'ወታደር ንቦች ቀፎውን ይከላከላሉ። ንግሥት ንቦች ብዙ እንቁላሎችን ይጥላሉ።',
      8: 'ላርቫዎች ከእንቁላል ይወጣሉ። እነሱ ብዙ ይበላሉ እና ፑፔ ይሆናሉ።',
      9: 'ፑፔዎች ወደ ጎልማሳ ንቦች ይለወጣሉ። ጎልማሶቹ ሥራ ይጀምራሉ!',
    },
    backgroundImageUrl: 'https://nqyegstlgecsutcsmtdx.supabase.co/storage/v1/object/public/book1/table.jpg',
    category: 'science',
    module: 'nature',
  ),
  // Book 3: Butterflies
  BookConfig(
    bookId: 'book3',
    title: 'Butterflies',
    description: 'Learn about butterflies and their world',
    coverImage: 'https://nqyegstlgecsutcsmtdx.supabase.co/storage/v1/object/public/book1/fla0.jpg',
    pageImageUrls: [
      'https://nqyegstlgecsutcsmtdx.supabase.co/storage/v1/object/public/book1/fla0.jpg',
      'https://nqyegstlgecsutcsmtdx.supabase.co/storage/v1/object/public/book1/fla1-removebg-preview.png',
      'https://nqyegstlgecsutcsmtdx.supabase.co/storage/v1/object/public/book1/fla2-removebg-preview.png',
      'https://nqyegstlgecsutcsmtdx.supabase.co/storage/v1/object/public/book1/fla3-removebg-preview.png',
      'https://nqyegstlgecsutcsmtdx.supabase.co/storage/v1/object/public/book1/fla4-removebg-preview.png',
      'https://nqyegstlgecsutcsmtdx.supabase.co/storage/v1/object/public/book1/fla5-removebg-preview.png',
      'https://nqyegstlgecsutcsmtdx.supabase.co/storage/v1/object/public/book1/fla6-removebg-preview.png',
      'https://nqyegstlgecsutcsmtdx.supabase.co/storage/v1/object/public/book1/fla7-removebg-preview.png',
      'https://nqyegstlgecsutcsmtdx.supabase.co/storage/v1/object/public/book1/fla8-removebg-preview.png',
      'https://nqyegstlgecsutcsmtdx.supabase.co/storage/v1/object/public/book1/fla9-removebg-preview.png',
    ],
    audioUrls: [
      'https://nqyegstlgecsutcsmtdx.supabase.co/storage/v1/object/public/book1/fla0_audio.ogg',
      'https://nqyegstlgecsutcsmtdx.supabase.co/storage/v1/object/public/book1/fla1_audio.ogg',
      'https://nqyegstlgecsutcsmtdx.supabase.co/storage/v1/object/public/book1/fla2_audio.ogg',
      'https://nqyegstlgecsutcsmtdx.supabase.co/storage/v1/object/public/book1/fla3_audio.ogg',
      'https://nqyegstlgecsutcsmtdx.supabase.co/storage/v1/object/public/book1/fla4_audio.ogg',
      'https://nqyegstlgecsutcsmtdx.supabase.co/storage/v1/object/public/book1/fla5_audio.ogg',
      'https://nqyegstlgecsutcsmtdx.supabase.co/storage/v1/object/public/book1/fla6_audio.ogg',
      'https://nqyegstlgecsutcsmtdx.supabase.co/storage/v1/object/public/book1/fla7_audio.ogg',
      'https://nqyegstlgecsutcsmtdx.supabase.co/storage/v1/object/public/book1/fla8_audio.ogg',
      'https://nqyegstlgecsutcsmtdx.supabase.co/storage/v1/object/public/book1/fla9_audio.ogg',
    ],
    pageTexts: {
      1: 'ቢራቢሮዎች ቆንጆ ነፍሳት ናቸው። እነሱ በቀለማት ያሸበረቁ ክንፎች አሏቸው።',
      2: 'ቢራቢሮዎች ስድስት እግሮች እና አንቴናዎች አሏቸው። እነሱ በአበባዎች ላይ ይመገባሉ።',
      3: 'ቢራቢሮዎች በአንቴናቸው ይሸታሉ። ይህ ምግብ እንዲያገኙ ይረዳቸዋል።',
      4: 'ቢራቢሮዎች ከእንቁላል ይወጣሉ። ላርቫዎች ተብለው ይጠራሉ።',
      5: 'ላርቫዎች ብዙ ቅጠሎችን ይበላሉ። እነሱ ክሪሳሊስ ይሆናሉ።',
      6: 'ክሪሳሊስ ውስጥ ቢራቢሮ ይፈጠራል። ይህ ለውጥ ነው።',
      7: 'ቢራቢሮዎች ከክሪሳሊስ ይወጣሉ። ክንፎቻቸውን ያሰፋሉ።',
      8: 'ቢራቢሮዎች የአበባ ማር ይጠጣሉ። ይህ ምግባቸው ነው።',
      9: 'ቢራቢሮዎች እንቁላል ይጥላሉ። ዑደቱ እንደገና ይጀምራል።',
    },
    backgroundImageUrl: 'https://nqyegstlgecsutcsmtdx.supabase.co/storage/v1/object/public/book1/table.jpg',
    category: 'science',
    module: 'nature',
  ),
  // Book 4: Counting
  BookConfig(
    bookId: 'book4',
    title: 'Counting',
    description: 'Learn to count with fun images',
    coverImage: 'https://nqyegstlgecsutcsmtdx.supabase.co/storage/v1/object/public/book1/cap.jpg',
    pageImageUrls: [
      'https://nqyegstlgecsutcsmtdx.supabase.co/storage/v1/object/public/book1/cap.jpg',
      'https://nqyegstlgecsutcsmtdx.supabase.co/storage/v1/object/public/book1/cap1-removebg-preview.png',
      'https://nqyegstlgecsutcsmtdx.supabase.co/storage/v1/object/public/book1/cap2-removebg-preview.png',
      'https://nqyegstlgecsutcsmtdx.supabase.co/storage/v1/object/public/book1/cap3-removebg-preview.png',
      'https://nqyegstlgecsutcsmtdx.supabase.co/storage/v1/object/public/book1/cap4-removebg-preview.png',
      'https://nqyegstlgecsutcsmtdx.supabase.co/storage/v1/object/public/book1/cap5-removebg-preview.png',
      'https://nqyegstlgecsutcsmtdx.supabase.co/storage/v1/object/public/book1/cap6-removebg-preview.png',
      'https://nqyegstlgecsutcsmtdx.supabase.co/storage/v1/object/public/book1/cap7-removebg-preview.png',
      'https://nqyegstlgecsutcsmtdx.supabase.co/storage/v1/object/public/book1/cap8-removebg-preview.png',
      'https://nqyegstlgecsutcsmtdx.supabase.co/storage/v1/object/public/book1/cap9-removebg-preview.png',
      'https://nqyegstlgecsutcsmtdx.supabase.co/storage/v1/object/public/book1/cap10-removebg-preview.png',
    ],
    audioUrls: [
      'https://nqyegstlgecsutcsmtdx.supabase.co/storage/v1/object/public/book1/cap0_audio.ogg',
      'https://nqyegstlgecsutcsmtdx.supabase.co/storage/v1/object/public/book1/cap1_audio.ogg',
      'https://nqyegstlgecsutcsmtdx.supabase.co/storage/v1/object/public/book1/cap2_audio.ogg',
      'https://nqyegstlgecsutcsmtdx.supabase.co/storage/v1/object/public/book1/cap3_audio.ogg',
      'https://nqyegstlgecsutcsmtdx.supabase.co/storage/v1/object/public/book1/cap4_audio.ogg',
      'https://nqyegstlgecsutcsmtdx.supabase.co/storage/v1/object/public/book1/cap5_audio.ogg',
      'https://nqyegstlgecsutcsmtdx.supabase.co/storage/v1/object/public/book1/cap6_audio.ogg',
      'https://nqyegstlgecsutcsmtdx.supabase.co/storage/v1/object/public/book1/cap7_audio.ogg',
      'https://nqyegstlgecsutcsmtdx.supabase.co/storage/v1/object/public/book1/cap8_audio.ogg',
      'https://nqyegstlgecsutcsmtdx.supabase.co/storage/v1/object/public/book1/cap9_audio.ogg',
      'https://nqyegstlgecsutcsmtdx.supabase.co/storage/v1/object/public/book1/cap10_audio.ogg',
    ],
    pageTexts: {
      1: 'አንድ ኮፍያ። አንድ ነገር እንቁጠር።',
      2: 'ሁለት ኮፍያዎች። ሁለት ነገሮች እንቁጠር።',
      3: 'ሦስት ኮፍያዎች። ሦስት ነገሮች እንቁጠር።',
      4: 'አራቴ ኮፍያዎች። አራት ነገሮች እንቁጠር።',
      5: 'አምስት ኮፍያዎች። አምስት ነገሮች እንቁጠር።',
      6: 'ስድስት ኮፍዤዎች። ስድስት ነገሮች እንቁጠር።',
      7: 'ሰባት ኮፍያዎች። ሰባት ነገሮች እንቁጠር።',
      8: 'ስምንት ኮፍያዎች። ስምንት ነገሮች እንቁጠር።',
      9: 'ዘጠኝ ኮፍያዎች። ዘጠኝ ነገሮች እንቁጠር።',
      10: 'አስር ኮፍያዎች። አስር ነገሮች እንቁጠር።',
    },
    backgroundImageUrl: 'https://nqyegstlgecsutcsmtdx.supabase.co/storage/v1/object/public/book1/table.jpg',
    category: 'math',
    module: 'math',
  ),
];

// Fetch admin-created books from Supabase via backend
Future<List<BookConfig>> fetchAdminBooks() async {
  final storage = const FlutterSecureStorage();
  try {
    final token = await storage.read(key: 'jwt_token');
    if (token == null) {
      throw Exception('Authentication Error: Please log in again.');
    }
    final response = await http.get(
      Uri.parse('https://backend-lesu72cxy-g4s-projects-7b5d827c.vercel.app/books'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((item) {
        final pageTexts = Map<String, String>.from(item['page_texts'] ?? {});
        final convertedPageTexts = pageTexts.map((key, value) => MapEntry(int.parse(key), value));

        return BookConfig(
          bookId: item['book_id'],
          title: item['title'],
          description: item['description'],
          coverImage: item['cover_image'],
          pageImageUrls: List<String>.from(item['page_image_urls']),
          audioUrls: List<String>.from(item['audio_urls']),
          pageTexts: convertedPageTexts,
          backgroundImageUrl: item['background_image_url'],
          category: item['category'] ?? 'general',
          module: 'new',
        );
      }).toList();
    } else {
      throw Exception('Failed to fetch books: ${response.reasonPhrase}');
    }
  } catch (e) {
    debugPrint("Error fetching admin books: $e");
    return [];
  }
}