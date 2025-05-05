import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:video_player/video_player.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'dart:async';

// --- Constants ---
const String BASE_URL = 'http://ethsld.aau.edu.et/ESLDS/public';
const String API_BASE = '$BASE_URL/api';
const String MEDIA_BASE = '$BASE_URL/assets/uploads/media_content';
const int DETAIL_PRELOAD_COUNT = 2; // How many future word *details* to preload
const String GOOGLE_API_KEY = 'AIzaSyDRHILO8lU0HEwauNOhZUYHl9mSXW6UxYQ'; // Your Google API key
const String CSE_ID = '9088503bc16f040e4'; // Your Custom Search Engine ID
const int IMAGE_PRELOAD_COUNT = 3; // How many images to fetch per word
const int IMAGE_MAX_DISPLAY = 3; // Max images to display per word
const int TOTAL_VIDEOS = 3300; // Total videos for progress calculation

// --- Utility Functions ---
Future<void> _preloadMedia(Map<String, dynamic> details, int wordIndex) async {
  print(">>> Preload Task: Downloading media for index $wordIndex");
  List<dynamic>? contents = details['contents'];
  if (contents == null || contents.isEmpty) {
    print(">>> Preload Task Skipped: No 'contents' for index $wordIndex");
    return;
  }
  for (var content in contents) {
    if (content == null || content is! Map) continue;
    final fileName = content['fileName']?.toString();
    if (fileName == null || fileName.isEmpty) continue;
    final isVideo = fileName.toLowerCase().endsWith('.mov') ||
        fileName.toLowerCase().endsWith('.mp4');
    if (isVideo) {
      final mediaUrl = '$MEDIA_BASE/$fileName';
      try {
        print(">>> Preload Task: Calling downloadFile for $mediaUrl");
        await DefaultCacheManager().downloadFile(mediaUrl);
        print(">>> Preload Task Success: downloadFile completed for $mediaUrl");
      } catch (e) {
        print(
            ">>> Preload Task Error: Failed to download/cache media $mediaUrl: $e");
      }
    }
  }
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sign Language Videos',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const VideoListScreen(),
    );
  }
}

// ================= Video List Screen =================
class VideoListScreen extends StatefulWidget {
  const VideoListScreen({super.key});

  @override
  _VideoListScreenState createState() => _VideoListScreenState();
}

class _VideoListScreenState extends State<VideoListScreen> {
  List<dynamic> words = [];
  bool isLoading = true;
  bool isLoadingMore = false;
  bool _canLoadMore = true;
  String selectedLanguage = 'English';
  int selectedLanguageId = 0;
  int currentPage = 1;
  final ScrollController _scrollController = ScrollController();

  final Map<String, int> languageMap = {
    'English': 0,
    'Amharic': 1,
    'Afaan Oromoo': 2,
    'Somalia': 3,
    'Tigrinya': 4,
  };

  @override
  void initState() {
    super.initState();
    _markSignLanguageOpened();
    fetchWords();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 300 &&
          !isLoadingMore &&
          _canLoadMore) {
        _loadMoreWords();
      }
    });
  }

  Future<void> _markSignLanguageOpened() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('sign_language_opened', true);
    await prefs.setInt('sign_language_last_opened', DateTime.now().millisecondsSinceEpoch);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> fetchWords({int page = 1, int limit = 20}) async {
    if (page > 1 && (isLoadingMore || !_canLoadMore)) return;
    setState(() {
      if (page == 1) {
        isLoading = true;
        words.clear();
        _canLoadMore = true;
      } else {
        isLoadingMore = true;
      }
    });
    try {
      final url = Uri.parse(
          '$API_BASE/Dictionary-Item/Word/$selectedLanguageId/$limit?page=$page');
      final response = await http.get(url).timeout(const Duration(seconds: 15));
      if (!mounted) return;
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true &&
            data['data'] != null &&
            data['data']['data'] is List) {
          List<dynamic> fetchedWords = List.from(data['data']['data']);
          if (fetchedWords.length < limit || fetchedWords.isEmpty) {
            _canLoadMore = false;
          }
          if (page > 1) {
            fetchedWords.removeWhere((newWord) =>
                words.any((existingWord) => existingWord?['id'] == newWord?['id']));
          }
          setState(() {
            words.addAll(fetchedWords);
            _sortWords();
            isLoading = false;
            isLoadingMore = false;
            if (fetchedWords.isNotEmpty) currentPage = page;
          });
          if (page == 1) _prefetchInitialDetails(words);
        } else {
          setState(() {
            isLoading = false;
            isLoadingMore = false;
            _canLoadMore = false;
          });
        }
      } else {
        throw Exception('Failed to load words: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      print('Error fetching words: $e\n$stackTrace');
      if (mounted) {
        setState(() {
          isLoading = false;
          isLoadingMore = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Error fetching words: ${e.toString().substring(0, (e.toString().length > 100 ? 100 : e.toString().length))}...')),
        );
      }
    }
  }

  void _sortWords() {
    if (selectedLanguage == 'English') {
      words.sort((a, b) => (a?['term'] ?? '')
          .toString()
          .toLowerCase()
          .compareTo((b?['term'] ?? '').toString().toLowerCase()));
    } else {
      words.sort((a, b) => (a?['transTerm'] ?? '')
          .toString()
          .toLowerCase()
          .compareTo((b?['transTerm'] ?? '').toString().toLowerCase()));
    }
  }

  Future<void> _prefetchInitialDetails(List<dynamic> wordList,
      {int startIndex = 0}) async {
    if (wordList.isEmpty) return;
    print(
        ">>> Detail Preload: Starting detail prefetch from index $startIndex for $DETAIL_PRELOAD_COUNT words.");
    final prefs = await SharedPreferences.getInstance();
    for (int i = 0;
        i < DETAIL_PRELOAD_COUNT && (startIndex + i) < wordList.length;
        i++) {
      final int currentIndex = startIndex + i;
      final wordData = wordList[currentIndex];
      if (wordData == null || wordData['id'] == null) continue;

      final termId = wordData['id'] as int;
      final cacheKey = 'word_details_$termId';

      // Fetch and cache word details
      if (prefs.getString(cacheKey) == null) {
        try {
          final detailUrl =
              Uri.parse('$API_BASE/Get-RandWord-Detail2/$termId');
          print(
              ">>> Detail Preload: Fetching details for index $currentIndex (term $termId)");
          final detailResponse =
              await http.get(detailUrl).timeout(const Duration(seconds: 8));
          if (detailResponse.statusCode == 200) {
            final detailData = json.decode(detailResponse.body);
            if (detailData['success'] == true && detailData['data'] != null) {
              await prefs.setString(cacheKey, json.encode(detailData['data']));
              print('>>> Detail Preload: Cached details for termId: $termId');
              // Preload video
              final details = detailData['data'] as Map<String, dynamic>?;
              if (details != null) {
                await _preloadMedia(details, currentIndex);
              }
            }
          }
        } catch (e) {
          print('>>> Detail Preload Error: Failed for termId $termId: $e');
        }
      } else {
        print(
            ">>> Detail Preload: Details for index $currentIndex (term $termId) already cached.");
      }

      // Prefetch images for this word
      final term = wordData['term']?.toString() ?? '';
      final cacheKeyImages = 'image_urls_$termId';
      if (prefs.getString(cacheKeyImages) == null) {
        try {
          final cachedDetails = prefs.getString(cacheKey);
          if (cachedDetails == null) continue;
          final detailData = json.decode(cachedDetails);
          final supportWords =
              (detailData['support_words'] as List<dynamic>?)?.cast<String>() ??
                  [];
          final query = supportWords.isNotEmpty ? supportWords.join(' ') : term;
          if (query.isNotEmpty) {
            print(
                ">>> Image Preload: Fetching images for query '$query' (termId $termId)");
            final imageUrls = await _fetchImageUrls(query);
            if (imageUrls.isNotEmpty) {
              await prefs.setString(cacheKeyImages, json.encode(imageUrls));
              print(
                  ">>> Image Preload: Cached ${imageUrls.length} image URLs for termId $termId");
              // Preload images into cache
              for (var url in imageUrls) {
                DefaultCacheManager()
                    .downloadFile(url)
                    .catchError((e) => print(">>> Image Cache Error: $e"));
              }
            } else {
              print(">>> Image Preload: No images found for query '$query'");
            }
          }
        } catch (e) {
          print(">>> Image Preload Error for termId $termId: $e");
        }
      }
    }
    print(">>> Detail Preload: Finished detail prefetch attempt.");
  }

  Future<List<String>> _fetchImageUrls(String query) async {
    final encodedQuery = Uri.encodeQueryComponent(query);
    final url = Uri.parse(
        'https://www.googleapis.com/customsearch/v1?key=$GOOGLE_API_KEY&cx=$CSE_ID&q=$encodedQuery&searchType=image&num=$IMAGE_PRELOAD_COUNT&safe=high');
    try {
      final response = await http.get(url).timeout(const Duration(seconds: 10));
      print(
          ">>> Image Fetch: Response status for query '$query': ${response.statusCode}");
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['items'] != null) {
          final urls = (data['items'] as List)
              .where((item) => item['link'] != null)
              .map<String>((item) => item['link'] as String)
              .toList();
          print(
              ">>> Image Fetch: Found ${urls.length} images for query '$query'");
          return urls;
        } else {
          print(">>> Image Fetch: No items in response for query '$query'");
          return [];
        }
      } else {
        print(
            ">>> Image Fetch: Failed with status ${response.statusCode} for query '$query'");
        return [];
      }
    } catch (e) {
      print(">>> Image Fetch Error for query '$query': $e");
      return [];
    }
  }

  Future<void> _clearCache() async {
    final confirmation = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Clear Cache'),
          content: const Text(
              'This will remove downloaded videos, images, and word details. Are you sure?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: const Text('Clear Cache'),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );
    if (confirmation == true && mounted) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      await DefaultCacheManager().emptyCache();
      setState(() {
        isLoading = true;
        currentPage = 1;
        words = [];
        _canLoadMore = true;
      });
      fetchWords();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cache cleared')),
      );
    }
  }

  Future<void> _loadMoreWords() async {
    await fetchWords(page: currentPage + 1);
  }

  void _navigateToWord(int index) {
    _prefetchInitialDetails(words, startIndex: index + 1);
    if (index >= 0 && index < words.length) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => WordDetailsScreen(
            words: List.from(words),
            initialIndex: index,
            selectedLanguage: selectedLanguage,
            languageMap: languageMap,
            onLanguageChanged: (newLanguage) {
              if (!mounted) return;
              setState(() {
                selectedLanguage = newLanguage;
                selectedLanguageId = languageMap[newLanguage] ?? 0;
                isLoading = true;
                currentPage = 1;
                _canLoadMore = true;
              });
              fetchWords(page: 1);
            },
          ),
        ),
      );
    } else {
      print("Error: Attempted to navigate to invalid index $index");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: Could not open word.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Language Videos'),
        actions: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: DropdownButton<String>(
              value: selectedLanguage,
              dropdownColor: Colors.blueGrey[700],
              style: const TextStyle(color: Colors.white),
              iconEnabledColor: Colors.white,
              underline: Container(),
              onChanged: (String? newValue) {
                if (newValue != null && newValue != selectedLanguage) {
                  if (!mounted) return;
                  setState(() {
                    selectedLanguage = newValue;
                    selectedLanguageId = languageMap[newValue] ?? 0;
                    isLoading = true;
                    currentPage = 1;
                    _canLoadMore = true;
                  });
                  fetchWords(page: 1);
                }
              },
              items: languageMap.keys
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: _clearCache,
            tooltip: 'Clear Cache',
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : words.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(
                      'No words found for $selectedLanguage.\nTry selecting a different language or check your connection.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                )
              : ListView.builder(
                  controller: _scrollController,
                  itemCount: words.length + (isLoadingMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == words.length) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }
                    final word = words[index];
                    if (word == null) return const SizedBox.shrink();
                    final displayTerm = selectedLanguage == 'English'
                        ? (word['term'] ?? 'N/A')
                        : (word['transTerm'] ?? 'N/A');
                    return ListTile(
                      title: Text(displayTerm),
                      onTap: () => _navigateToWord(index),
                      visualDensity: VisualDensity.compact,
                    );
                  },
                ),
    );
  }
}

// ================= Word Details Screen =================
class WordDetailsScreen extends StatefulWidget {
  final List<dynamic> words;
  final int initialIndex;
  final String selectedLanguage;
  final Map<String, int> languageMap;
  final Function(String) onLanguageChanged;

  const WordDetailsScreen({
    super.key,
    required this.words,
    required this.initialIndex,
    required this.selectedLanguage,
    required this.languageMap,
    required this.onLanguageChanged,
  });

  @override
  _WordDetailsScreenState createState() => _WordDetailsScreenState();
}

class _WordDetailsScreenState extends State<WordDetailsScreen> {
  late int currentIndex;
  Map<String, dynamic>? wordDetails;
  List<String> imageUrls = [];
  bool isLoading = true;
  bool isLoadingImages = true;
  String? error;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;
    fetchWordDetails();
    fetchImages();
  }

  Future<void> fetchWordDetails() async {
    if (!mounted) return;
    setState(() {
      isLoading = true;
      error = null;
      wordDetails = null;
    });
    if (currentIndex < 0 || currentIndex >= widget.words.length) {
      if (mounted) {
        setState(() {
          isLoading = false;
          error = "Invalid word index.";
        });
      }
      return;
    }
    final currentWordData = widget.words[currentIndex];
    final termId = currentWordData?['id'] as int?;
    if (termId == null) {
      if (mounted) {
        setState(() {
          isLoading = false;
          error = "Word data is missing ID.";
        });
      }
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = 'word_details_$termId';
      final cachedData = prefs.getString(cacheKey);
      if (cachedData != null) {
        if (!mounted) return;
        print("Details found in cache for CURRENT termId: $termId");
        wordDetails = json.decode(cachedData);
      } else {
        print('Fetching details from network for CURRENT termId $termId');
        final url = Uri.parse('$API_BASE/Get-RandWord-Detail2/$termId');
        final response = await http.get(url).timeout(const Duration(seconds: 15));
        if (!mounted) return;
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data['success'] == true && data['data'] != null) {
            wordDetails = data['data'];
            await prefs.setString(cacheKey, json.encode(wordDetails));
            if (wordDetails != null) {
              await _preloadMedia(wordDetails!, currentIndex);
            }
          } else {
            throw Exception('API returned success:false or missing data.');
          }
        } else {
          throw Exception('Failed to load word details: ${response.statusCode}');
        }
      }
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
      _triggerSingleVideoPreload();
    } catch (e, stackTrace) {
      print('Error fetching word details for index $currentIndex: $e\n$stackTrace');
      if (mounted) {
        setState(() {
          error = e.toString();
          isLoading = false;
        });
      }
    }
  }

  Future<void> fetchImages() async {
    if (!mounted) return;
    setState(() {
      isLoadingImages = true;
      imageUrls = [];
    });
    final currentWordData = widget.words[currentIndex];
    final termId = currentWordData?['id'] as int?;
    final term = currentWordData?['term']?.toString() ?? '';
    if (termId == null) {
      if (mounted) {
        setState(() {
          isLoadingImages = false;
        });
      }
      return;
    }

    final cacheKey = 'image_urls_$termId';
    final prefs = await SharedPreferences.getInstance();
    final cachedImages = prefs.getString(cacheKey);
    if (cachedImages != null) {
      print("Images found in cache for termId: $termId");
      if (mounted) {
        setState(() {
          imageUrls = List<String>.from(json.decode(cachedImages));
          isLoadingImages = false;
        });
      }
    } else {
      try {
        final supportWords =
            (wordDetails?['support_words'] as List<dynamic>?)?.cast<String>() ??
                [];
        final query = supportWords.isNotEmpty ? supportWords.join(' ') : term;
        if (query.isEmpty) {
          print(">>> Image Fetch: No query available for termId $termId");
          if (mounted) {
            setState(() {
              isLoadingImages = false;
            });
          }
          return;
        }
        print(">>> Image Fetch: Searching for query '$query' (termId $termId)");
        final urls = await _fetchImageUrls(query);
        if (urls.isNotEmpty) {
          await prefs.setString(cacheKey, json.encode(urls));
          // Preload images into cache
          for (var url in urls) {
            DefaultCacheManager()
                .downloadFile(url)
                .catchError((e) => print(">>> Image Cache Error: $e"));
          }
        }
        if (mounted) {
          setState(() {
            imageUrls = urls;
            isLoadingImages = false;
          });
        }
      } catch (e) {
        print("Error fetching images for termId $termId: $e");
        if (mounted) {
          setState(() {
            isLoadingImages = false;
          });
        }
      }
    }
  }

  Future<List<String>> _fetchImageUrls(String query) async {
    final encodedQuery = Uri.encodeQueryComponent(query);
    final url = Uri.parse(
        'https://www.googleapis.com/customsearch/v1?key=$GOOGLE_API_KEY&cx=$CSE_ID&q=$encodedQuery&searchType=image&num=$IMAGE_PRELOAD_COUNT&safe=high');
    try {
      final response = await http.get(url).timeout(const Duration(seconds: 10));
      print(
          ">>> Image Fetch: Response status for query '$query': ${response.statusCode}");
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['items'] != null) {
          final urls = (data['items'] as List)
              .where((item) => item['link'] != null)
              .map<String>((item) => item['link'] as String)
              .toList();
          print(
              ">>> Image Fetch: Found ${urls.length} images for query '$query'");
          return urls;
        } else {
          print(">>> Image Fetch: No items in response for query '$query'");
          return [];
        }
      } else {
        print(
            ">>> Image Fetch: Failed with status ${response.statusCode} for query '$query'");
        return [];
      }
    } catch (e) {
      print(">>> Image Fetch Error for query '$query': $e");
      return [];
    }
  }

  void _triggerSingleVideoPreload() {
    final nextIndex = currentIndex + 1;
    if (nextIndex < widget.words.length) {
      print(
          ">>> Video Preload: Triggering background preload for NEXT index: $nextIndex");
      _fetchAndPreloadVideosForIndex(nextIndex).catchError((e) {
        print(
            ">>> Video Preload Error (Background): Preload failed for index $nextIndex: $e");
      });
    } else {
      print(
          ">>> Video Preload: No next word to preload video for (currently at index $currentIndex).");
    }
  }

  Future<void> _fetchAndPreloadVideosForIndex(int indexToPreload) async {
    print(
        ">>> Video Preload Task: Fetch/Cache details & video for index $indexToPreload");
    Map<String, dynamic>? detailsToPreload;
    int? termIdToPreload;
    try {
      final wordData = widget.words[indexToPreload];
      termIdToPreload = wordData?['id'] as int?;
      if (termIdToPreload == null) {
        print(
            ">>> Preload Task Skipped: Missing termId for index $indexToPreload");
        return;
      }
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = 'word_details_$termIdToPreload';
      final cachedDetailsJson = prefs.getString(cacheKey);
      if (cachedDetailsJson != null) {
        print(
            ">>> Preload Task: Details for index $indexToPreload found in SharedPreferences.");
        detailsToPreload = json.decode(cachedDetailsJson);
      } else {
        print(
            ">>> Preload Task: Fetching details for index $indexToPreload from network.");
        final detailUrl =
            Uri.parse('$API_BASE/Get-RandWord-Detail2/$termIdToPreload');
        final response =
            await http.get(detailUrl).timeout(const Duration(seconds: 10));
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data['success'] == true && data['data'] != null) {
            detailsToPreload = data['data'];
            await prefs.setString(cacheKey, json.encode(detailsToPreload));
            print(
                ">>> Preload Task: Fetched and cached details for index $indexToPreload");
          } else {
            throw Exception(
                "API success=false or no data for index $indexToPreload");
          }
        } else {
          throw Exception(
              "Network error ${response.statusCode} fetching details for index $indexToPreload");
        }
      }
      if (detailsToPreload != null) {
        final nonNullableDetails = detailsToPreload;
        await _preloadMedia(nonNullableDetails, indexToPreload);
      }
    } catch (e) {
      print(
          ">>> Preload Task Error (Index $indexToPreload, Term $termIdToPreload): $e");
      throw Exception("Failed preloading for index $indexToPreload: $e");
    }
  }

  Future<void> _incrementWatchedCount() async {
    final prefs = await SharedPreferences.getInstance();
    int watchedCount = prefs.getInt('watched_words_count') ?? 0;
    watchedCount += 1;
    await prefs.setInt('watched_words_count', watchedCount);
  }

  void _navigateNext() {
    if (currentIndex < widget.words.length - 1) {
      if (!mounted) return;
      _prefetchDetailsForNavigation(currentIndex + 2);
      _incrementWatchedCount();
      setState(() {
        currentIndex++;
      });
      fetchWordDetails();
      fetchImages();
    }
  }

  void _navigatePrevious() {
    if (currentIndex > 0) {
      if (!mounted) return;
      _prefetchDetailsForNavigation(currentIndex);
      setState(() {
        currentIndex--;
      });
      fetchWordDetails();
      fetchImages();
    }
  }

  void _prefetchDetailsForNavigation(int startIndex) {
    _VideoListScreenState()
        ._prefetchInitialDetails(widget.words, startIndex: startIndex)
        .catchError((e) => print("Error during navigation detail prefetch: $e"));
  }

  Map<String, dynamic>? _getFirstVideoData(Map<String, dynamic>? details) {
    if (details == null) return null;
    List<dynamic>? contents = details['contents'];
    if (contents == null || contents.isEmpty) return null;
    try {
      return contents.firstWhere(
          (c) {
            if (c == null || c is! Map) return false;
            final ct = c['contentType']?.toString().toLowerCase();
            final fn = c['fileName']?.toString().toLowerCase();
            return ct == 'video' ||
                (fn != null &&
                    fn.isNotEmpty &&
                    (fn.endsWith('.mov') || fn.endsWith('.mp4')));
          },
          orElse: () => null) as Map<String, dynamic>?;
    } catch (e) {
      print("Error in _getFirstVideoData: $e");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentWordData =
        (currentIndex >= 0 && currentIndex < widget.words.length)
            ? widget.words[currentIndex]
            : null;
    final firstVideoData = _getFirstVideoData(wordDetails);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Word Details'),
        actions: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: DropdownButton<String>(
              value: widget.selectedLanguage,
              dropdownColor: Colors.blueGrey[700],
              style: const TextStyle(color: Colors.white),
              iconEnabledColor: Colors.white,
              underline: Container(),
              onChanged: (String? newValue) {
                if (newValue != null && newValue != widget.selectedLanguage) {
                  widget.onLanguageChanged(newValue);
                  Navigator.pop(context);
                }
              },
              items: widget.languageMap.keys
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline,
                            color: Colors.red, size: 50),
                        const SizedBox(height: 10),
                        Text('Error loading details:\n$error',
                            textAlign: TextAlign.center),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            fetchWordDetails();
                            fetchImages();
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              : (wordDetails != null && currentWordData != null)
                  ? SingleChildScrollView(
                      padding: const EdgeInsets.all(8.0),
                      child: WordItem(
                        key: ValueKey(
                            'word_${currentWordData['id']}_$currentIndex'),
                        term: currentWordData['term'] ?? 'N/A',
                        transTerm: currentWordData['transTerm'] ?? 'N/A',
                        translations:
                            wordDetails!['translations'] as List<dynamic>? ?? [],
                        videoData: firstVideoData,
                        imageUrls: imageUrls,
                        isLoadingImages: isLoadingImages,
                        selectedLanguage: widget.selectedLanguage,
                        languageMap: widget.languageMap,
                        termId: currentWordData['id']?.toString() ?? 'unknown_id',
                      ),
                    )
                  : const Center(
                      child: Text('No details available for this word.')),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: currentIndex > 0 ? _navigatePrevious : null,
            backgroundColor: currentIndex > 0
                ? Theme.of(context).colorScheme.primary
                : Colors.grey,
            heroTag: 'previous_word',
            tooltip: 'Previous Word',
            child: const Icon(Icons.arrow_back),
          ),
          const SizedBox(width: 16),
          FloatingActionButton(
            onPressed:
                currentIndex < widget.words.length - 1 ? _navigateNext : null,
            backgroundColor: currentIndex < widget.words.length - 1
                ? Theme.of(context).colorScheme.primary
                : Colors.grey,
            heroTag: 'next_word',
            tooltip: 'Next Word',
            child: const Icon(Icons.arrow_forward),
          ),
        ],
      ),
    );
  }
}

// ================= Video Item Widget =================
class VideoItem extends StatefulWidget {
  final String videoUrl;
  final String? thumbnailUrl;
  final String termId;

  const VideoItem({
    required this.videoUrl,
    this.thumbnailUrl,
    required this.termId,
    super.key,
  });

  @override
  _VideoItemState createState() => _VideoItemState();
}

class _VideoItemState extends State<VideoItem> {
  VideoPlayerController? _controller;
  Future<void>? _initializeVideoPlayerFuture;
  bool _isPlaying = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    print(
        "VideoItem initState for termId: ${widget.termId}, URL: ${widget.videoUrl}");
    _initializeVideoPlayerFuture = _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    if (!mounted) return;
    print("Attempting to initialize video: ${widget.videoUrl}");
    _errorMessage = null;
    await _controller?.dispose();
    _controller = null;
    try {
      FileInfo? fileInfo =
          await DefaultCacheManager().getFileFromCache(widget.videoUrl);
      if (fileInfo != null && await fileInfo.file.exists()) {
        print(">>> Video found in cache: ${fileInfo.file.path}");
        _controller = VideoPlayerController.file(
          fileInfo.file,
          videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
        );
      } else {
        print(
            ">>> Video not in cache, initializing from network: ${widget.videoUrl}");
        _controller = VideoPlayerController.networkUrl(
          Uri.parse(widget.videoUrl),
          videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
        );
        DefaultCacheManager()
            .downloadFile(widget.videoUrl)
            .then((_) {
              print(
                  ">>> Background cache download initiated for ${widget.videoUrl}");
            })
            .catchError((e) {
              print(
                  ">>> Background cache download failed for ${widget.videoUrl}: $e");
            });
      }
      await _controller!.initialize();
      print("Video initialized successfully: ${widget.videoUrl}");
      _controller!.addListener(_videoListener);
      if (!mounted) {
        await _controller?.dispose();
        return;
      }
      setState(() {});
    } catch (error, stackTrace) {
      print(
          "Video initialization error for ${widget.videoUrl}: $error\n$stackTrace");
      if (mounted) {
        setState(() {
          _errorMessage = error.toString();
        });
      }
    }
  }

  void _videoListener() {
    if (!mounted || _controller == null || !_controller!.value.isInitialized) {
      return;
    }
    final bool currentlyPlaying = _controller!.value.isPlaying;
    if (currentlyPlaying != _isPlaying) {
      setState(() {
        _isPlaying = currentlyPlaying;
      });
    }
    if (_controller!.value.position >= _controller!.value.duration &&
        !_controller!.value.isPlaying) {
      _controller?.seekTo(Duration.zero);
      if (_isPlaying) {
        setState(() {
          _isPlaying = false;
        });
      }
    }
  }

  void _playPauseVideo() {
    if (_controller != null && _controller!.value.isInitialized) {
      if (_controller!.value.isPlaying) {
        _controller!.pause();
      } else {
        if (_controller!.value.position >= _controller!.value.duration) {
          _controller!.seekTo(Duration.zero).then((_) => _controller!.play());
        } else {
          _controller!.play();
        }
      }
    } else if (_errorMessage != null) {
      print("Retrying initialization...");
      if (mounted) {
        setState(() {
          _initializeVideoPlayerFuture = _initializeVideo();
        });
      }
    } else {
      print("Play/Pause ignored: Controller not ready.");
    }
  }

  void _replayVideo() {
    if (_controller != null && _controller!.value.isInitialized) {
      _controller!.seekTo(Duration.zero).then((_) {
        if (!_controller!.value.isPlaying) _controller!.play();
      });
    } else {
      print("Replay ignored: Controller not ready.");
    }
  }

  @override
  void dispose() {
    print(
        "Disposing VideoItem for termId: ${widget.termId}, URL: ${widget.videoUrl}");
    final capturedController = _controller;
    _controller = null;
    capturedController?.removeListener(_videoListener);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      capturedController?.dispose();
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('Building VideoItem UI for ${widget.videoUrl}');
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      child: Column(
        children: [
          FutureBuilder(
            future: _initializeVideoPlayerFuture,
            builder: (context, snapshot) {
              final bool isInitialized = snapshot.connectionState ==
                      ConnectionState.done &&
                  !snapshot.hasError &&
                  _errorMessage == null &&
                  _controller != null &&
                  _controller!.value.isInitialized;

              if (isInitialized) {
                print(
                    "VideoItem FutureBuilder: Initialized - ${widget.videoUrl}");
                return AspectRatio(
                  aspectRatio: _controller!.value.aspectRatio > 0
                      ? _controller!.value.aspectRatio
                      : 16 / 9,
                  child: VideoPlayer(_controller!),
                );
              } else if (snapshot.hasError || _errorMessage != null) {
                print(
                    "VideoItem FutureBuilder: Error - ${widget.videoUrl}, Error: ${snapshot.error ?? _errorMessage}");
                return _buildErrorWidget();
              } else {
                print(
                    "VideoItem FutureBuilder: Waiting/Loading - ${widget.videoUrl}");
                return _buildLoadingPlaceholder();
              }
            },
          ),
          Container(
            color: Colors.grey[100],
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(_isPlaying
                      ? Icons.pause_circle_filled
                      : Icons.play_circle_filled),
                  iconSize: 36,
                  tooltip: _isPlaying ? 'Pause' : 'Play',
                  onPressed: _playPauseVideo,
                ),
                const SizedBox(width: 16),
                IconButton(
                  icon: const Icon(Icons.replay_circle_filled),
                  iconSize: 36,
                  tooltip: 'Replay',
                  onPressed: _replayVideo,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingPlaceholder() {
    return Container(
      height: 200,
      color: Colors.grey[300],
      child: Center(
        child: (widget.thumbnailUrl != null && widget.thumbnailUrl!.isNotEmpty)
            ? Image.network(
                '$MEDIA_BASE/${widget.thumbnailUrl}',
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2.0,
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) => Icon(
                    Icons.video_file_rounded,
                    color: Colors.grey[600],
                    size: 50),
              )
            : CircularProgressIndicator(
                strokeWidth: 3.0, color: Theme.of(context).primaryColor),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      height: 200,
      color: Colors.grey[200],
      padding: const EdgeInsets.all(16),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.red.shade700, size: 40),
            const SizedBox(height: 12),
            Text(
              'Error loading video',
              style: TextStyle(
                  color: Colors.red.shade700, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              onPressed: () {
                if (mounted) {
                  setState(() {
                    _errorMessage = null;
                    _initializeVideoPlayerFuture = _initializeVideo();
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ================= Word Item Widget =================
class WordItem extends StatelessWidget {
  final String term;
  final String transTerm;
  final List<dynamic> translations;
  final Map<String, dynamic>? videoData;
  final List<String> imageUrls;
  final bool isLoadingImages;
  final String selectedLanguage;
  final Map<String, int> languageMap;
  final String termId;

  const WordItem({
    required this.term,
    required this.transTerm,
    required this.translations,
    required this.videoData,
    required this.imageUrls,
    required this.isLoadingImages,
    required this.selectedLanguage,
    required this.languageMap,
    required this.termId,
    super.key,
  });

  String getTranslatedTerm() {
    if (selectedLanguage == 'English') return term;
    final translation = translations.firstWhere(
      (t) => (t is Map && t['name'] == selectedLanguage),
      orElse: () => null,
    );
    return (translation != null && translation['transTerm'] != null)
        ? translation['transTerm'].toString()
        : transTerm;
  }

  @override
  Widget build(BuildContext context) {
    final String displayTerm = getTranslatedTerm();
    print(
        'Building WordItem for termId: $termId, VideoData: ${videoData != null}, Images: ${imageUrls.length}');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          displayTerm,
          style: Theme.of(context)
              .textTheme
              .headlineMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        if (selectedLanguage != 'English' && term != displayTerm)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              'English: $term',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(color: Colors.grey[700]),
            ),
          ),
        const Divider(thickness: 1),
        const SizedBox(height: 8),
        if (videoData != null)
          Builder(
            builder: (context) {
              final fileName = videoData!['fileName'];
              final thumbnailUrl = videoData!['thumbnail'];
              if (fileName == null || fileName.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 24.0),
                    child: Text(
                      'Video data incomplete.',
                      style: TextStyle(color: Colors.orange),
                    ),
                  ),
                );
              }
              final videoUrl = '$MEDIA_BASE/$fileName';
              print('Rendering VideoItem for URL: $videoUrl');
              return VideoItem(
                videoUrl: videoUrl,
                thumbnailUrl: thumbnailUrl,
                termId: termId,
              );
            },
          )
        else
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24.0),
            child: Center(
              child: Text(
                'No video available for this term.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ),
          ),
        const SizedBox(height: 16),
        Text(
          'Related Images',
          style: Theme.of(context)
              .textTheme
              .titleLarge
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        isLoadingImages
            ? const Center(child: CircularProgressIndicator())
            : imageUrls.isEmpty
                ? const Center(
                    child: Text(
                      'No images found for this term.',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  )
                : SizedBox(
                    height: 150,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: imageUrls.length > IMAGE_MAX_DISPLAY
                          ? IMAGE_MAX_DISPLAY
                          : imageUrls.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Image.network(
                              imageUrls[index],
                              width: 150,
                              height: 150,
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Container(
                                  width: 150,
                                  height: 150,
                                  color: Colors.grey[300],
                                  child: const Center(
                                      child: CircularProgressIndicator(
                                    strokeWidth: 2.0,
                                  )),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                width: 150,
                                height: 150,
                                color: Colors.grey[300],
                                child: const Center(
                                  child: Text(
                                    'Failed to load image',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
      ],
    );
  }
}

