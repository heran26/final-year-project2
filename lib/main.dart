import 'package:flutter/material.dart';
import 'register.dart';
import 'login.dart';
import 'verify.dart';
import 'reset_password.dart';
import 'avatar_girl.dart';
import 'avatar_boy.dart';
import 'main2.dart';
import 'translate.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    // Listen to locale changes
    AppTranslations.localeNotifier.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Welcome App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        textTheme: const TextTheme(
          bodyMedium: TextStyle(fontFamily: 'NotoSansEthiopic'),
        ),
      ),
      locale: AppTranslations.localeNotifier.value,
      supportedLocales: AppTranslations.supportedLocales,
      localizationsDelegates: AppTranslations.localizationsDelegates,
      initialRoute: '/welcome',
      routes: {
        '/welcome': (context) => const WelcomeScreen(),
        '/register': (context) => const RegisterScreen(),
        '/verify': (context) => VerifyScreen(email: ModalRoute.of(context)!.settings.arguments as String),
        '/login': (context) => const LoginScreen(),
        '/reset-password': (context) => ResetPasswordScreen(email: ModalRoute.of(context)!.settings.arguments as String),
        '/avatar_girl': (context) => const GirlsAvatarPickerScreen(),
        '/avatar_boy': (context) => const AvatarPickerScreen(),
        '/main': (context) => const MainPage(),
      },
    );
  }
}

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
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
            left: 1.5 * widthScale,
            top: 97 * heightScale,
            child: Image.asset(
              'assets/maingif.gif',
              width: 357 * widthScale,
              height: 283 * heightScale,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            left: -50 * widthScale,
            top: -50 * heightScale,
            child: Image.asset(
              'assets/blue.png',
              width: 450 * widthScale,
              height: 210 * heightScale,
            ),
          ),
          Positioned(
            left: -75 * widthScale,
            top: -94 * heightScale,
            child: Image.asset(
              'assets/topp.png',
              width: 300 * widthScale,
              height: 300 * heightScale,
            ),
          ),
          Positioned(
            left: 145 * widthScale,
            top: -15 * heightScale,
            child: Image.asset(
              'assets/topp2.png',
              width: 400 * widthScale,
              height: 400 * heightScale,
            ),
          ),
          Positioned(
            left: -78 * widthScale,
            top: -75 * heightScale,
            child: Image.asset(
              'assets/top1.png',
              width: 300 * widthScale,
              height: 300 * heightScale,
            ),
          ),
          Positioned(
            left: 133 * widthScale,
            top: -103 * heightScale,
            child: Image.asset(
              'assets/top2.png',
              width: 400 * widthScale,
              height: 400 * heightScale,
            ),
          ),
          Positioned(
            left: 223 * widthScale,
            top: -10 * heightScale,
            child: Image.asset(
              'assets/abeba-removebg-preview 1.png',
              width: 169 * widthScale,
              height: 169 * heightScale,
            ),
          ),
          Positioned(
            left: 169 * widthScale,
            top: 40 * heightScale,
            child: Image.asset(
              'assets/abeba-removebg-preview 2.png',
              width: 106 * widthScale,
              height: 106 * heightScale,
            ),
          ),
          Positioned(
            left: 0 * widthScale,
            top: 421 * heightScale,
            child: Image.asset(
              'assets/abeba-removebg-preview.png',
              width: 91 * widthScale,
              height: 91 * heightScale,
            ),
          ),
          Positioned(
            left: 269 * widthScale,
            top: 467 * heightScale,
            child: Image.asset(
              'assets/abeba-removebg-preview.png',
              width: 91 * widthScale,
              height: 91 * heightScale,
            ),
          ),
          Positioned(
            left: -66 * widthScale,
            top: 560 * heightScale,
            child: Image.asset(
              'assets/image 2.png',
              width: 93 * widthScale,
              height: 93 * heightScale,
            ),
          ),
          Positioned(
            left: 21 * widthScale,
            top: 560 * heightScale,
            child: Image.asset(
              'assets/image 2.png',
              width: 93 * widthScale,
              height: 93 * heightScale,
            ),
          ),
          Positioned(
            left: 109 * widthScale,
            top: 561 * heightScale,
            child: Image.asset(
              'assets/image 2.png',
              width: 91 * widthScale,
              height: 91 * heightScale,
            ),
          ),
          Positioned(
            left: 195 * widthScale,
            top: 561 * heightScale,
            child: Image.asset(
              'assets/image 2.png',
              width: 91 * widthScale,
              height: 91 * heightScale,
            ),
          ),
          Positioned(
            left: 284 * widthScale,
            top: 565 * heightScale,
            child: Image.asset(
              'assets/image 2.png',
              width: 84 * widthScale,
              height: 84 * heightScale,
            ),
          ),
          Positioned(
            left: 43 * widthScale,
            top: 399 * heightScale,
            child: SizedBox(
              width: 275 * widthScale,
              height: 21 * heightScale,
              child: Center(
                child: Text(
                  AppTranslations.translate('welcome', context),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF3E3E3E),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 105 * widthScale,
            top: 436 * heightScale,
            child: Container(
              width: 153 * widthScale,
              height: 40 * heightScale,
              decoration: BoxDecoration(
                color: const Color(0xFFFFCB7C),
                borderRadius: BorderRadius.circular(50 * widthScale),
                boxShadow: const [
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
            left: 160 * widthScale,
            top: 444 * heightScale,
            child: SizedBox(
              width: 40 * widthScale,
              height: 22 * heightScale,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/login');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                ),
                child: Center(
                  child: Text(
                    AppTranslations.translate('login', context),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Color(0xDE000000),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 105 * widthScale,
            top: 488 * heightScale,
            child: Container(
              width: 153 * widthScale,
              height: 40 * heightScale,
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF2CA2B0)),
                borderRadius: BorderRadius.circular(50 * widthScale),
              ),
            ),
          ),
          Positioned(
            left: 150 * widthScale,
            top: 496 * heightScale,
            child: SizedBox(
              width: 60 * widthScale,
              height: 22 * heightScale,
              child: TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/register');
                },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.transparent,
                  overlayColor: Colors.transparent,
                ),
                child: Center(
                  child: Text(
                    AppTranslations.translate('register', context),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Color(0xDE000000),
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
}