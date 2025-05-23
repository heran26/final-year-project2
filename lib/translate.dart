import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class AppTranslations {
  static const supportedLocales = [
    Locale('en', 'US'), // English
    Locale('am', 'ET'), // Amharic
  ];

  static final ValueNotifier<Locale> localeNotifier = ValueNotifier(const Locale('en', 'US'));

  static Map<String, Map<String, String>> _translations = {
    'en_US': {
      'welcome': 'WELCOME',
      'login': 'Login',
      'register': 'Register',
      'account': 'Account',
      'progress': 'Progress',
      'screen_time': 'Screen Time',
      'change_avatar': 'Change Avatar',
      'translate_to_amharic': 'Translate to Amharic',
      'logout': 'Logout',
      'delete_account': 'Delete Account',
      'please_log_in': 'Please log in',
      'error': 'Error',
      'logged_out_successfully': 'Logged out successfully',
      'account_deleted_successfully': 'Account deleted successfully',
      'delete_account_confirm_title': 'Delete Account',
      'delete_account_confirm_content': 'Are you sure you want to permanently delete your account? This action cannot be undone.',
      'cancel': 'Cancel',
      'delete': 'Delete',
      'gender_unavailable': 'Gender information unavailable',
      'science': 'Science',
      'math': 'Math',
      'language': 'Language',
      'esl': 'ESL',
      'daily': 'Daily',
      'weekly': 'Weekly',
      'monthly': 'Monthly',
      'yearly': 'Yearly',
    },
    'am_ET': {
      'welcome': 'እኳን ደህና መጡ',
      'login': 'ግባ',
      'register': 'መዝገብ',
      'account': 'መለያ',
      'progress': 'እድገት',
      'screen_time': 'የማያ ጊዜ',
      'change_avatar': 'አቫታር ቀይር',
      'translate_to_amharic': 'ወደ አማርኛ ተርጉም',
      'logout': 'ውጣ',
      'delete_account': 'መለያ ሰርዝ',
      'please_log_in': 'እባክህ ግባ',
      'error': 'ስህተት',
      'logged_out_successfully': 'በተሳካ ሁኔታ ወጥተሃል',
      'account_deleted_successfully': 'መለያ በተሳካ ሁኔታ ተሰርዟል',
      'delete_account_confirm_title': 'መለያ ሰርዝ',
      'delete_account_confirm_content': 'መለያህን በቋሚነት መሰረዝ እንደምትፈልግ እርግጠኛ ነህ? ይህ ተግባር መቀልበስ አይችልም።',
      'cancel': 'ሰርዝ',
      'delete': 'ሰርዝ',
      'gender_unavailable': 'የፆታ መረጃ አይገኝም',
      'science': 'ሳይንስ',
      'math': 'ሒሳብ',
      'language': 'ቋንቋ',
      'esl': 'እንግሊዝኛ እንደ ሁለተኛ ቋንቋ',
      'daily': 'የዕለት',
      'weekly': 'ሳምንታዊ',
      'monthly': 'ወርሃዊ',
      'yearly': 'ዓመታዊ',
    },
  };

  static String translate(String key, BuildContext context) {
    final locale = Localizations.localeOf(context).toString();
    return _translations[locale]?[key] ?? _translations['en_US']![key]!;
  }

  static List<LocalizationsDelegate> get localizationsDelegates => [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ];

  static void setLocale(Locale newLocale) {
    if (supportedLocales.contains(newLocale)) {
      localeNotifier.value = newLocale;
    }
  }
}