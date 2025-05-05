import 'package:flutter/material.dart';

class BookConfig {
  final String bookId;
  final String title;
  final String description;
  final String coverImage;
  final List<String> pageImageUrls;
  final List<String> audioUrls;
  final Map<int, String> pageTexts;
  final String backgroundImageUrl;

  BookConfig({
    required this.bookId,
    required this.title,
    required this.description,
    required this.coverImage,
    required this.pageImageUrls,
    required this.audioUrls,
    required this.pageTexts,
    required this.backgroundImageUrl,
  });
}

// List of all books
final List<BookConfig> books = [
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
      9: 'ፑፔዎች ወደ ጎልማሳ ጉንዳኖች ይለወጣሉ። ጎልማሶቹ ወዲያውኑ ሥራ ይጀምራሉ!',
    },
    backgroundImageUrl: 'https://nqyegstlgecsutcsmtdx.supabase.co/storage/v1/object/public/book1/table.jpg',
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
      // Replace with actual audio URLs for the Bees book if available
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
  ),

    BookConfig(
    bookId: 'book3',
    title: 'Bees',
    description: 'Learn about bees and their world',
    coverImage: 'https://nqyegstlgecsutcsmtdx.supabase.co/storage/v1/object/public/book1//fla0.jpg',
    pageImageUrls: [
      'https://nqyegstlgecsutcsmtdx.supabase.co/storage/v1/object/public/book1//fla0.jpg',
      'https://nqyegstlgecsutcsmtdx.supabase.co/storage/v1/object/public/book1//fla1-removebg-preview.png',
      'https://nqyegstlgecsutcsmtdx.supabase.co/storage/v1/object/public/book1//fla2-removebg-preview.png',
      'https://nqyegstlgecsutcsmtdx.supabase.co/storage/v1/object/public/book1//fla3-removebg-preview.png',
      'https://nqyegstlgecsutcsmtdx.supabase.co/storage/v1/object/public/book1//fla4-removebg-preview.png',
      'https://nqyegstlgecsutcsmtdx.supabase.co/storage/v1/object/public/book1//fla5-removebg-preview.png',
      'https://nqyegstlgecsutcsmtdx.supabase.co/storage/v1/object/public/book1//fla6-removebg-preview.png',
      'https://nqyegstlgecsutcsmtdx.supabase.co/storage/v1/object/public/book1//fla7-removebg-preview.png',
      'https://nqyegstlgecsutcsmtdx.supabase.co/storage/v1/object/public/book1//fla8-removebg-preview.png',
      'https://nqyegstlgecsutcsmtdx.supabase.co/storage/v1/object/public/book1//fla9-removebg-preview.png',
    ],
    audioUrls: [
      // Replace with actual audio URLs for the Bees book if available
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
  ),
      BookConfig(
    bookId: 'book4',
    title: 'Bees',
    description: 'Learn about bees and their world',
    coverImage: 'https://nqyegstlgecsutcsmtdx.supabase.co/storage/v1/object/public/book1//cap.jpg',
    pageImageUrls: [
      'https://nqyegstlgecsutcsmtdx.supabase.co/storage/v1/object/public/book1//cap.jpg',
      'https://nqyegstlgecsutcsmtdx.supabase.co/storage/v1/object/public/book1//cap1-removebg-preview.png',
      'https://nqyegstlgecsutcsmtdx.supabase.co/storage/v1/object/public/book1//cap2-removebg-preview.png',
      'https://nqyegstlgecsutcsmtdx.supabase.co/storage/v1/object/public/book1//cap3-removebg-preview.png',
      'https://nqyegstlgecsutcsmtdx.supabase.co/storage/v1/object/public/book1//cap4-removebg-preview.png',
      'https://nqyegstlgecsutcsmtdx.supabase.co/storage/v1/object/public/book1//cap5-removebg-preview.png',
      'https://nqyegstlgecsutcsmtdx.supabase.co/storage/v1/object/public/book1//cap6-removebg-preview.png',
      'https://nqyegstlgecsutcsmtdx.supabase.co/storage/v1/object/public/book1//cap7-removebg-preview.png',
      'https://nqyegstlgecsutcsmtdx.supabase.co/storage/v1/object/public/book1//cap8-removebg-preview.png',
      'https://nqyegstlgecsutcsmtdx.supabase.co/storage/v1/object/public/book1//cap9-removebg-preview.png',
      'https://nqyegstlgecsutcsmtdx.supabase.co/storage/v1/object/public/book1//cap10-removebg-preview.png',
    ],
    audioUrls: [
      // Replace with actual audio URLs for the Bees book if available
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
  ),
  // Placeholder books (book3 to book21)
  ...List.generate(19, (index) {
    String bookId = 'book${index + 3}';
    return BookConfig(
      bookId: bookId,
      title: 'Book ${index + 3} Title',
      description: 'Description for Book ${index + 3}',
      coverImage: 'https://nqyegstlgecsutcsmtdx.supabase.co/storage/v1/object/public/placeholder/cover.jpg',
      pageImageUrls: [
        'https://nqyegstlgecsutcsmtdx.supabase.co/storage/v1/object/public/placeholder/page${index + 3}_1.jpg',
        'https://nqyegstlgecsutcsmtdx.supabase.co/storage/v1/object/public/placeholder/page${index + 3}_2.jpg',
      ],
      audioUrls: [
        'https://nqyegstlgecsutcsmtdx.supabase.co/storage/v1/object/public/placeholder/audio${index + 3}_1.mp3',
        'https://nqyegstlgecsutcsmtdx.supabase.co/storage/v1/object/public/placeholder/audio${index + 3}_2.mp3',
      ],
      pageTexts: {
        1: 'Sample text for $bookId page 1',
        2: 'Sample text for $bookId page 2',
      },
      backgroundImageUrl: 'https://nqyegstlgecsutcsmtdx.supabase.co/storage/v1/object/public/placeholder/background.jpg',
    );
  }),
];