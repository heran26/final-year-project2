import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'book_assets.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://nqyegstlgecsutcsmtdx.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5xeWVnc3RsZ2Vjc3V0Y3NtdGR4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDUxNTc4NzksImV4cCI6MjA2MDczMzg3OX0.eBFTmfqz-29Z0cEeXq8zX8dBJFfZ6LUisu4VoJRKCFM',
  );
  runApp(const PreloadApp(bookId: 'book1'));
}

class PreloadApp extends StatefulWidget {
  final String bookId;
  const PreloadApp({super.key, required this.bookId});
  @override
  _PreloadAppState createState() => _PreloadAppState();
}

class _PreloadAppState extends State<PreloadApp> {
  Future<Map<String, dynamic>> _preloadInitialAssets() async {
    final bookConfig = books.firstWhere(
      (book) => book.bookId == widget.bookId,
      orElse: () => throw Exception('Book not found'),
    );

    // Get the saved page index to preload relevant images
    final prefs = await SharedPreferences.getInstance();
    final savedPageIndex = prefs.getInt('${widget.bookId}_currentPage') ?? 0;

    Map<String, ui.Image> preloadedImages = {};
    // Preload first two pages, last page (if different), and the page at savedPageIndex
    final initialImageUrls = {
      ...bookConfig.pageImageUrls.take(2),
      if (savedPageIndex >= 2) bookConfig.pageImageUrls[savedPageIndex],
      if (bookConfig.pageImageUrls.length > 2) bookConfig.pageImageUrls.last,
    };

    for (String url in initialImageUrls) {
      try {
        final image = await _loadNetworkImage(CachedNetworkImageProvider(url));
        preloadedImages[url] = image;
      } catch (e) {
        debugPrint("Error loading image $url: $e");
      }
    }

    try {
      final bgImage = await _loadNetworkImage(CachedNetworkImageProvider(bookConfig.backgroundImageUrl));
      preloadedImages[bookConfig.backgroundImageUrl] = bgImage;
    } catch (e) {
      debugPrint("Error loading background image: $e");
    }

    final tempDir = await getTemporaryDirectory();
    Map<String, String> audioLocalPaths = {};
    // Preload audio for first two pages and the saved page
    final initialAudioUrls = {
      ...bookConfig.audioUrls.take(2),
      if (savedPageIndex < bookConfig.audioUrls.length && savedPageIndex >= 2) bookConfig.audioUrls[savedPageIndex],
    };

    for (String url in initialAudioUrls) {
      try {
        final fileName = url.split('/').last;
        final filePath = '${tempDir.path}/$fileName';
        if (!await File(filePath).exists()) {
          final response = await http.get(Uri.parse(url));
          if (response.statusCode == 200) {
            await File(filePath).writeAsBytes(response.bodyBytes);
            audioLocalPaths[url] = filePath;
          }
        } else {
          audioLocalPaths[url] = filePath;
        }
      } catch (e) {
        debugPrint("Error preloading audio $url: $e");
      }
    }

    return {
      'images': preloadedImages,
      'audioLocalPaths': audioLocalPaths,
      'bookConfig': bookConfig,
    };
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: FutureBuilder<Map<String, dynamic>>(
        future: _preloadInitialAssets(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingScreen();
          } else if (snapshot.hasError) {
            debugPrint("FutureBuilder error: ${snapshot.error}");
            return ErrorScreen(
              onRetry: () => setState(() {}),
            );
          } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            return BookApp(
              bookId: widget.bookId,
              preloadedImages: snapshot.data!['images'],
              audioLocalPaths: snapshot.data!['audioLocalPaths'],
              bookConfig: snapshot.data!['bookConfig'],
            );
          } else {
            return ErrorScreen(
              onRetry: () => setState(() {}),
            );
          }
        },
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

Future<ui.Image> _loadNetworkImage(CachedNetworkImageProvider provider) async {
  final completer = Completer<ui.Image>();
  final stream = provider.resolve(ImageConfiguration.empty);
  late ImageStreamListener listener;
  listener = ImageStreamListener(
    (ImageInfo info, bool _) {
      if (!completer.isCompleted) completer.complete(info.image);
      stream.removeListener(listener);
    },
    onError: (exception, stackTrace) {
      if (!completer.isCompleted) completer.completeError(exception, stackTrace);
      stream.removeListener(listener);
    },
  );
  stream.addListener(listener);
  return completer.future;
}

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading book...'),
          ],
        ),
      ),
    );
  }
}

class ErrorScreen extends StatelessWidget {
  final VoidCallback? onRetry;
  const ErrorScreen({super.key, this.onRetry});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Failed to load book. Please check your connection.',
              style: TextStyle(color: Colors.red, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

class BookApp extends StatelessWidget {
  final String bookId;
  final Map<String, ui.Image> preloadedImages;
  final Map<String, String> audioLocalPaths;
  final BookConfig bookConfig;

  const BookApp({
    super.key,
    required this.bookId,
    required this.preloadedImages,
    required this.audioLocalPaths,
    required this.bookConfig,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Book Reader',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: BookReader(
        bookId: bookId,
        preloadedImages: preloadedImages,
        audioLocalPaths: audioLocalPaths,
        bookConfig: bookConfig,
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

class BookReader extends StatefulWidget {
  final String bookId;
  final Map<String, ui.Image> preloadedImages;
  final Map<String, String> audioLocalPaths;
  final BookConfig bookConfig;

  const BookReader({
    super.key,
    required this.bookId,
    required this.preloadedImages,
    required this.audioLocalPaths,
    required this.bookConfig,
  });

  @override
  _BookReaderState createState() => _BookReaderState();
}

class _BookReaderState extends State<BookReader> with TickerProviderStateMixin {
  static const double textBoxLeft = 130.0;
  static const double textBoxTop = 90.0;
  static const double textBoxWidth = 220.0;
  static const double textBoxHeight = 230.0;

  int currentPageIndex = 0;
  int _textResetCounter = 0;
  late AnimationController _controller;
  late AnimationController _slideController;
  bool isAnimating = false;
  bool isSliding = false;
  bool isTurningForward = true;
  late Map<int, ui.Image> _loadedPages;
  ui.Image? backgroundImage;
  late AudioPlayer _audioPlayer;
  late SharedPreferences _prefs;
  double readingProgress = 0.0;
  bool _isLoadingMoreAssets = false;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _loadedPages = {};
    _initializeBook();
  }

  Future<void> _initializeBook() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      final savedPageIndex = _prefs.getInt('${widget.bookId}_currentPage') ?? 0;
      setState(() {
        currentPageIndex = savedPageIndex.clamp(0, widget.bookConfig.pageImageUrls.length - 1);
        readingProgress = _calculateProgress();
      });

      // Initialize with preloaded images
      _loadedPages.clear();
      for (int i = 0; i < widget.bookConfig.pageImageUrls.length; i++) {
        final url = widget.bookConfig.pageImageUrls[i];
        if (widget.preloadedImages.containsKey(url)) {
          _loadedPages[i] = widget.preloadedImages[url]!;
        }
      }

      backgroundImage = widget.preloadedImages[widget.bookConfig.backgroundImageUrl];
      _audioPlayer = AudioPlayer();

      // Ensure the current page's image is loaded
      if (!_loadedPages.containsKey(currentPageIndex)) {
        await _loadSpecificPage(currentPageIndex);
      }

      _playAudioForPage(currentPageIndex);

      _controller = AnimationController(
        duration: const Duration(milliseconds: 800),
        vsync: this,
      );
      _slideController = AnimationController(
        duration: const Duration(milliseconds: 400),
        vsync: this,
      );
      _controller.addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          setState(() {
            currentPageIndex = isTurningForward ? currentPageIndex + 1 : currentPageIndex - 1;
            _updateProgressAndSave();
            isAnimating = false;
            _controller.reset();
            if (currentPageIndex % 2 == 1 && !_isLoadingMoreAssets) {
              _preloadNextChunk();
            }
          });
        }
      });
      _slideController.addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          setState(() {
            isSliding = false;
            _slideController.reset();
            isAnimating = true;
            _controller.forward();
            _updateProgressAndSave();
          });
        }
      });

      // Preload additional pages if needed
      await _preloadNextChunk();

      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      debugPrint("Error initializing book: $e");
      setState(() {
        _isInitialized = false;
      });
    }
  }

  Future<void> _loadSpecificPage(int pageIndex) async {
    if (pageIndex < 0 || pageIndex >= widget.bookConfig.pageImageUrls.length) return;
    if (_loadedPages.containsKey(pageIndex)) return;

    try {
      final url = widget.bookConfig.pageImageUrls[pageIndex];
      final image = await _loadNetworkImage(CachedNetworkImageProvider(url));
      setState(() {
        _loadedPages[pageIndex] = image;
      });

      // Also preload the audio for this page
      final tempDir = await getTemporaryDirectory();
      final audioUrl = widget.bookConfig.audioUrls[pageIndex];
      final fileName = audioUrl.split('/').last;
      final filePath = '${tempDir.path}/$fileName';
      if (!await File(filePath).exists()) {
        final response = await http.get(Uri.parse(audioUrl));
        if (response.statusCode == 200) {
          await File(filePath).writeAsBytes(response.bodyBytes);
        }
      }
    } catch (e) {
      debugPrint("Error loading page $pageIndex: $e");
    }
  }

  Future<void> _preloadNextChunk() async {
    if (_isLoadingMoreAssets) return;
    _isLoadingMoreAssets = true;

    try {
      final nextChunkStart = _loadedPages.isEmpty ? 0 : _loadedPages.keys.last + 1;
      if (nextChunkStart >= widget.bookConfig.pageImageUrls.length) return;

      for (int i = nextChunkStart; i < nextChunkStart + 2 && i < widget.bookConfig.pageImageUrls.length; i++) {
        if (!_loadedPages.containsKey(i)) {
          try {
            final url = widget.bookConfig.pageImageUrls[i];
            final image = await _loadNetworkImage(CachedNetworkImageProvider(url));
            setState(() {
              _loadedPages[i] = image;
            });
          } catch (e) {
            debugPrint("Error loading page $i: $e");
          }
        }
      }

      final tempDir = await getTemporaryDirectory();
      for (int i = nextChunkStart; i < nextChunkStart + 2 && i < widget.bookConfig.audioUrls.length; i++) {
        try {
          final url = widget.bookConfig.audioUrls[i];
          final fileName = url.split('/').last;
          final filePath = '${tempDir.path}/$fileName';
          if (!await File(filePath).exists()) {
            final response = await http.get(Uri.parse(url));
            if (response.statusCode == 200) {
              await File(filePath).writeAsBytes(response.bodyBytes);
            }
          }
        } catch (e) {
          debugPrint("Error loading audio for page $i: $e");
        }
      }
    } finally {
      setState(() {
        _isLoadingMoreAssets = false;
      });
    }
  }

  double _calculateProgress() {
    final totalPages = widget.bookConfig.pageImageUrls.length;
    return ((currentPageIndex + 1) / totalPages * 100).clamp(0.0, 100.0);
  }

  void _updateProgressAndSave() {
    setState(() {
      readingProgress = _calculateProgress();
    });
    _prefs.setInt('${widget.bookId}_currentPage', currentPageIndex);
    _prefs.setDouble('${widget.bookId}_progress', readingProgress);
  }

  @override
  void dispose() {
    _controller.dispose();
    _slideController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _playAudioForPage(int pageIndex) async {
    if (pageIndex >= 0 && pageIndex < widget.bookConfig.audioUrls.length) {
      final audioUrl = widget.bookConfig.audioUrls[pageIndex];
      final tempDir = await getTemporaryDirectory();
      final fileName = audioUrl.split('/').last;
      final filePath = '${tempDir.path}/$fileName';

      if (await File(filePath).exists()) {
        await _audioPlayer.stop();
        await _audioPlayer.play(DeviceFileSource(filePath));
      } else {
        debugPrint("Audio file for page $pageIndex not found");
        // Attempt to download the audio file
        try {
          final response = await http.get(Uri.parse(audioUrl));
          if (response.statusCode == 200) {
            await File(filePath).writeAsBytes(response.bodyBytes);
            await _audioPlayer.stop();
            await _audioPlayer.play(DeviceFileSource(filePath));
          }
        } catch (e) {
          debugPrint("Error downloading audio for page $pageIndex: $e");
        }
      }
    }
  }

  void _replay() {
    setState(() {
      _textResetCounter++;
      _playAudioForPage(currentPageIndex);
    });
  }

  int get maxPageIndex => widget.bookConfig.pageImageUrls.length - 1;

  bool _canTurnPage(bool forward) {
    if (isAnimating || isSliding) return false;
    return forward ? currentPageIndex < maxPageIndex : currentPageIndex > 0;
  }

  bool _checkImagesForTurn(bool forward) {
    int current = currentPageIndex;
    int next = current + 1;
    int prev = current - 1;

    if (forward) {
      if (next > maxPageIndex) return false;
      if (current == 0) return _loadedPages[0] != null && _loadedPages[1] != null;
      return _loadedPages[current] != null && _loadedPages[next] != null;
    } else {
      if (prev < 0) return false;
      if (current == 1) return _loadedPages[1] != null && _loadedPages[0] != null;
      return _loadedPages[current] != null && _loadedPages[prev] != null;
    }
  }

  void _goToNextPage() {
    if (!_canTurnPage(true)) return;
    isTurningForward = true;
    if (_checkImagesForTurn(true)) {
      setState(() {
        if (currentPageIndex == 0) {
          isSliding = true;
          _slideController.forward();
          _playAudioForPage(1);
        } else {
          isAnimating = true;
          _controller.forward();
          _playAudioForPage(currentPageIndex + 1);
        }
      });
    } else {
      // Load the next page if not available
      _loadSpecificPage(currentPageIndex + 1).then((_) {
        if (_checkImagesForTurn(true)) {
          setState(() {
            if (currentPageIndex == 0) {
              isSliding = true;
              _slideController.forward();
              _playAudioForPage(1);
            } else {
              isAnimating = true;
              _controller.forward();
              _playAudioForPage(currentPageIndex + 1);
            }
          });
        }
      });
    }
  }

  void _goToPreviousPage() {
    if (!_canTurnPage(false)) return;
    isTurningForward = false;
    if (_checkImagesForTurn(false)) {
      setState(() {
        isAnimating = true;
        _controller.forward();
        _playAudioForPage(currentPageIndex - 1);
      });
    } else {
      // Load the previous page if not available
      _loadSpecificPage(currentPageIndex - 1).then((_) {
        if (_checkImagesForTurn(false)) {
          setState(() {
            isAnimating = true;
            _controller.forward();
            _playAudioForPage(currentPageIndex - 1);
          });
        }
      });
    }
  }

  Widget _buildPageSide(int imageAssetIndex, bool isLeftHalf, Size availableSize) {
    if (!_isInitialized) {
      return Container(
        color: Colors.grey[200],
        width: availableSize.width,
        height: availableSize.height,
        alignment: Alignment.center,
        child: const CircularProgressIndicator(),
      );
    }

    final image = _loadedPages[imageAssetIndex];
    if (image == null) {
      // Trigger loading of the specific page
      _loadSpecificPage(imageAssetIndex);
      return Container(
        color: Colors.grey[200],
        width: availableSize.width,
        height: availableSize.height,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            const Text(
              'Loading page...',
              style: TextStyle(color: Colors.red, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => setState(() {}),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }
    return Stack(
      children: [
        CustomPaint(
          painter: _ImageHalfPainter(image, imageAssetIndex, isLeftHalf),
          size: availableSize,
        ),
        if (imageAssetIndex >= 1 && isLeftHalf)
          Positioned(
            left: textBoxLeft,
            top: textBoxTop,
            child: AnimatedTextBox(
              key: ValueKey('$imageAssetIndex-$_textResetCounter'),
              text: widget.bookConfig.pageTexts[imageAssetIndex] ?? 'No text available',
              width: textBoxWidth,
              height: textBoxHeight,
              durationPerWord: 400,
            ),
          ),
      ],
    );
  }

  Widget _buildStaticView(Size pageSideSize) {
    if (!_isInitialized) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (currentPageIndex == 0) {
      return Positioned(
        left: pageSideSize.width / 2,
        top: 0,
        width: pageSideSize.width,
        height: pageSideSize.height,
        child: _buildPageSide(0, false, pageSideSize),
      );
    } else {
      return Stack(
        children: [
          Positioned(
            left: 0,
            top: 0,
            width: pageSideSize.width,
            height: pageSideSize.height,
            child: _buildPageSide(currentPageIndex, true, pageSideSize),
          ),
          Positioned(
            left: pageSideSize.width,
            top: 0,
            width: pageSideSize.width,
            height: pageSideSize.height,
            child: _buildPageSide(currentPageIndex, false, pageSideSize),
          ),
        ],
      );
    }
  }

  Widget _buildAnimatingView(Size pageSideSize) {
    if (!_isInitialized) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    int baseIndex = isTurningForward ? currentPageIndex : currentPageIndex - 1;
    int currentIndex = currentPageIndex;

    int staticLIdx = -1, staticRIdx = -1, frontIdx = -1, backIdx = -1;
    bool frontLeft = false, backLeft = true;

    if (isTurningForward) {
      if (baseIndex == 0) {
        staticRIdx = 1;
        frontIdx = 0;
        frontLeft = false;
        backIdx = 1;
        backLeft = true;
      } else {
        staticLIdx = baseIndex;
        staticRIdx = baseIndex + 1;
        frontIdx = baseIndex;
        frontLeft = false;
        backIdx = baseIndex + 1;
        backLeft = true;
      }
    } else {
      if (currentIndex == 1) {
        staticRIdx = 1;
        frontIdx = 1;
        frontLeft = true;
        backIdx = 0;
        backLeft = false;
      } else {
        staticLIdx = currentIndex - 1;
        staticRIdx = currentIndex;
        frontIdx = currentIndex;
        frontLeft = true;
        backIdx = currentIndex - 1;
        backLeft = false;
      }
    }

    return Stack(
      children: [
        if (staticLIdx != -1)
          Positioned(
            left: 0,
            top: 0,
            width: pageSideSize.width,
            height: pageSideSize.height,
            child: _buildPageSide(staticLIdx, true, pageSideSize),
          ),
        if (staticRIdx != -1)
          Positioned(
            left: pageSideSize.width,
            top: 0,
            width: pageSideSize.width,
            height: pageSideSize.height,
            child: _buildPageSide(staticRIdx, false, pageSideSize),
          ),
        AnimatedBuilder(
          animation: isSliding ? _slideController : _controller,
          builder: (context, child) {
            if (isSliding && currentPageIndex == 0 && isTurningForward) {
              double slideValue = Curves.easeOut.transform(_slideController.value);
              double leftPosition = pageSideSize.width / 2 + slideValue * (pageSideSize.width / 2);
              return Positioned(
                left: leftPosition,
                top: 0,
                width: pageSideSize.width,
                height: pageSideSize.height,
                child: _buildPageSide(0, false, pageSideSize),
              );
            } else {
              double animValue = Curves.easeInOutSine.transform(_controller.value);
              double angle;
              Alignment alignment;
              bool pageStartsOnRight;
              bool showFront;

              if (isTurningForward) {
                angle = animValue * pi;
                alignment = Alignment.centerLeft;
                pageStartsOnRight = true;
                showFront = angle < (pi / 2);
              } else {
                angle = animValue * -pi;
                alignment = Alignment.centerRight;
                pageStartsOnRight = false;
                showFront = angle > (-pi / 2);
              }

              Widget pageFace;
              if (showFront) {
                pageFace = _buildPageSide(frontIdx, frontLeft, pageSideSize);
              } else {
                pageFace = Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()..rotateY(pi),
                  child: _buildPageSide(backIdx, backLeft, pageSideSize),
                );
              }

              double shadowOpacity = max(0.0, min(0.4, sin(animValue * pi).abs() * 0.6));

              return Positioned(
                left: pageStartsOnRight ? pageSideSize.width : 0,
                top: 0,
                width: pageSideSize.width,
                height: pageSideSize.height,
                child: Transform(
                  alignment: alignment,
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.0015)
                    ..rotateY(angle),
                  child: Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(shadowOpacity),
                          blurRadius: 8,
                          spreadRadius: 1,
                          offset: Offset(pageStartsOnRight ? -2 : 2, 0),
                        )
                      ],
                    ),
                    child: pageFace,
                  ),
                ),
              );
            }
          },
        ),
      ],
    );
  }

  Widget _buildNavigationArrows(BuildContext context) {
    bool canGoBack = _canTurnPage(false);
    bool canGoForward = _canTurnPage(true);

    return Stack(
      children: [
        Positioned(
          left: 20,
          top: 0,
          bottom: 0,
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Transform.rotate(
                    angle: pi / 2,
                    child: const Icon(Icons.arrow_back_ios, size: 40),
                  ),
                  color: canGoBack ? Colors.white : Colors.white.withOpacity(0.5),
                  onPressed: canGoBack ? _goToPreviousPage : null,
                ),
                IconButton(
                  icon: Transform.rotate(
                    angle: pi / 2,
                    child: const Icon(Icons.arrow_forward_ios, size: 40),
                  ),
                  color: canGoForward ? Colors.white : Colors.white.withOpacity(0.5),
                  onPressed: canGoForward ? _goToNextPage : null,
                ),
              ],
            ),
          ),
        ),
        Positioned(
          left: 20,
          top: 0,
          bottom: 0,
          child: SafeArea(
            child: Center(
              child: IconButton(
                icon: const Icon(Icons.refresh, size: 40),
                color: Colors.white,
                onPressed: _replay,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (backgroundImage != null)
            Positioned.fill(
              child: CustomPaint(painter: _BackgroundPainter(backgroundImage!)),
            ),
          if (_isLoadingMoreAssets && currentPageIndex > 0)
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Loading next pages...',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
          Positioned.fill(
            child: FittedBox(
              fit: BoxFit.contain,
              child: RotatedBox(
                quarterTurns: 1,
                child: SizedBox(
                  width: MediaQuery.of(context).size.height,
                  height: MediaQuery.of(context).size.width,
                  child: Stack(
                    children: [
                      if (!isAnimating && !isSliding)
                        _buildStaticView(Size(
                          MediaQuery.of(context).size.height / 2,
                          MediaQuery.of(context).size.width,
                        ))
                      else
                        _buildAnimatingView(Size(
                          MediaQuery.of(context).size.height / 2,
                          MediaQuery.of(context).size.width,
                        )),
                    ],
                  ),
                ),
              ),
            ),
          ),
          _buildNavigationArrows(context),
        ],
      ),
    );
  }
}

class AnimatedTextBox extends StatefulWidget {
  final String text;
  final double width;
  final double height;
  final int durationPerWord;

  const AnimatedTextBox({
    super.key,
    required this.text,
    required this.width,
    required this.height,
    this.durationPerWord = 1000,
  });

  @override
  _AnimatedTextBoxState createState() => _AnimatedTextBoxState();
}

class _AnimatedTextBoxState extends State<AnimatedTextBox> with SingleTickerProviderStateMixin {
  late AnimationController _textController;
  late Animation<int> _wordIndexAnimation;
  late List<String> _words;
  final List<Color> _colors = [
    Colors.yellow,
    Colors.green,
    Colors.red,
    Colors.blue,
    Colors.purple,
    Colors.pink,
  ];

  @override
  void initState() {
    super.initState();
    _words = widget.text.split(' ');
    if (_words.isEmpty) _words = ['No text'];

    _textController = AnimationController(
      duration: Duration(milliseconds: widget.durationPerWord * _words.length),
      vsync: this,
    );

    _wordIndexAnimation = IntTween(begin: 0, end: _words.length - 1).animate(
      CurvedAnimation(
        parent: _textController,
        curve: Curves.linear,
      ),
    );

    _textController.repeat();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height,
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(1),
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: Center(
        child: AnimatedBuilder(
          animation: _wordIndexAnimation,
          builder: (context, child) {
            int currentWordIndex = _wordIndexAnimation.value;
            Color currentColor = _colors[currentWordIndex % _colors.length];
            return RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                children: _words.asMap().entries.map((entry) {
                  int index = entry.key;
                  String word = entry.value;
                  return TextSpan(
                    text: '$word ',
                    style: TextStyle(
                      color: index == currentWordIndex ? currentColor : Colors.black,
                      fontSize: 23.0,
                      fontWeight: index == currentWordIndex ? FontWeight.bold : FontWeight.normal,
                    ),
                  );
                }).toList(),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ImageHalfPainter extends CustomPainter {
  final ui.Image image;
  final int imageIndex;
  final bool isLeftHalf;

  _ImageHalfPainter(this.image, this.imageIndex, this.isLeftHalf);

  @override
  void paint(Canvas canvas, Size size) {
    Rect srcRect;
    if (imageIndex == 0) {
      srcRect = Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble());
    } else {
      double halfWidth = image.width.toDouble() / 2.0;
      srcRect = isLeftHalf
          ? Rect.fromLTWH(0, 0, halfWidth, image.height.toDouble())
          : Rect.fromLTWH(halfWidth, 0, halfWidth, image.height.toDouble());
    }

    final dstRect = Rect.fromLTWH(0, 0, size.width, size.height);
    final BoxFit fit = BoxFit.contain;
    final FittedSizes fittedSizes = applyBoxFit(fit, srcRect.size, dstRect.size);
    final Rect finalSrcRect = Alignment.center.inscribe(fittedSizes.source, srcRect);
    final Rect finalDstRect = Alignment.center.inscribe(fittedSizes.destination, dstRect);

    canvas.drawImageRect(
      image,
      finalSrcRect,
      finalDstRect,
      Paint()..filterQuality = FilterQuality.high,
    );
  }

  @override
  bool shouldRepaint(covariant _ImageHalfPainter oldDelegate) {
    return image != oldDelegate.image ||
        imageIndex != oldDelegate.imageIndex ||
        isLeftHalf != oldDelegate.isLeftHalf;
  }
}

class _BackgroundPainter extends CustomPainter {
  final ui.Image image;

  _BackgroundPainter(this.image);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint p = Paint()..filterQuality = FilterQuality.high;
    final Size iS = Size(image.width.toDouble(), image.height.toDouble());
    final FittedSizes fS = applyBoxFit(BoxFit.cover, iS, size);
    final Rect iSub = Alignment.center.inscribe(fS.source, Offset.zero & iS);
    final Rect oSub = Alignment.center.inscribe(fS.destination, Offset.zero & size);
    canvas.drawImageRect(image, iSub, oSub, p);
  }

  @override
  bool shouldRepaint(covariant _BackgroundPainter oldDelegate) {
    return image != oldDelegate.image;
  }
}