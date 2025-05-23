import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fl_chart/fl_chart.dart';
import 'progress_calculate.dart';
import 'translate.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({Key? key}) : super(key: key);

  @override
  _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  String? _userName;
  String? _userEmail;
  String? _userAvatar;
  String? _userGender;
  bool _isLoadingUser = true;
  Map<String, Map<String, double>> _reportData = {};
  bool _isLoadingReport = true;
  String _progressTimeFrame = 'Daily';
  String _screenTimeFrame = 'Daily';
  final storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _fetchReportData();
  }

  Future<void> _fetchUserData() async {
    try {
      final token = await storage.read(key: 'jwt_token');
      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please log in')),
        );
        Navigator.pushReplacementNamed(context, '/login');
        return;
      }

      final url = Uri.parse('https://backend-lesu72cxy-g4s-projects-7b5d827c.vercel.app/user');
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _userName = data['name'];
          _userEmail = data['email'];
          _userAvatar = data['avatar'];
          _userGender = data['gender'];
          _isLoadingUser = false;
        });
      } else {
        final error = jsonDecode(response.body)['error'];
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $error')),
        );
        setState(() {
          _userName = 'User';
          _userEmail = 'user@example.com';
          _userAvatar = 'assets/avatar8.png';
          _userGender = 'unknown';
          _isLoadingUser = false;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
      setState(() {
        _userName = 'User';
        _userEmail = 'user@example.com';
        _userAvatar = 'assets/avatar8.png';
        _userGender = 'unknown';
        _isLoadingUser = false;
      });
    }
  }

  Future<void> _fetchReportData() async {
    try {
      setState(() {
        _isLoadingReport = true;
      });
      Map<String, Map<String, double>> report;
      switch (_progressTimeFrame) {
        case 'Weekly':
          report = await ProgressCalculator.getWeeklyReport();
          break;
        case 'Monthly':
          report = await ProgressCalculator.getMonthlyReport();
          break;
        case 'Yearly':
          report = await ProgressCalculator.getYearlyReport();
          break;
        case 'Daily':
        default:
          report = await ProgressCalculator.getDailyReport();
          break;
      }
      setState(() {
        _reportData = report;
        _isLoadingReport = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching report: $e')),
      );
      setState(() {
        _reportData = {
          'science': {'time': 0.0, 'progress': 0.0},
          'math': {'time': 0.0, 'progress': 0.0},
          'language': {'time': 0.0, 'progress': 0.0},
          'ESL': {'time': 0.0, 'progress': 0.0},
        };
        _isLoadingReport = false;
      });
    }
  }

  Future<void> _logout() async {
    try {
      await storage.delete(key: 'jwt_token');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Logged out successfully')),
      );
      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _deleteAccount() async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text('Are you sure you want to permanently delete your account? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final token = await storage.read(key: 'jwt_token');
      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please log in')),
        );
        Navigator.pushReplacementNamed(context, '/login');
        return;
      }

      final url = Uri.parse('https://backend-lesu72cxy-g4s-projects-7b5d827c.vercel.app/delete-account');
      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        await storage.delete(key: 'jwt_token');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account deleted successfully')),
        );
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        final error = jsonDecode(response.body)['error'];
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $error')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void _changeAvatar() {
    if (_userGender == null || _userGender == 'unknown') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gender information unavailable')),
      );
      return;
    }

    final route = _userGender == 'female' ? '/avatar_girl' : '/avatar_boy';
    Navigator.pushNamed(context, route);
  }

  double _getMaxYForTime() {
    final times = [
      (_reportData['science']?['time'] ?? 0.0) / 60.0,
      (_reportData['math']?['time'] ?? 0.0) / 60.0,
      (_reportData['language']?['time'] ?? 0.0) / 60.0,
      (_reportData['ESL']?['time'] ?? 0.0) / 60.0,
    ];
    final maxTime = times.reduce((a, b) => a > b ? a : b);
    final calculatedMax = maxTime <= 0.0 ? 5.0 : ((maxTime / 5.0).ceil() * 5.0);
    return calculatedMax.clamp(5.0, _progressTimeFrame == 'Daily' ? 30.0 : 1000.0) as double;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F1E5),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Account 🎉",
                  style: TextStyle(
                    fontFamily: 'Rubik',
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF251504),
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 65,
                        height: 63,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF8BE0),
                          border: Border.all(color: Colors.black, width: 5),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: _isLoadingUser || _userAvatar == null || _userAvatar!.isEmpty
                              ? Image.asset(
                                  'assets/avatar8.png',
                                  fit: BoxFit.cover,
                                )
                              : Image.asset(
                                  _userAvatar!,
                                  fit: BoxFit.cover,
                                ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _isLoadingUser ? 'User' : (_userName ?? 'User'),
                              style: const TextStyle(
                                fontFamily: 'Rubik',
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFFDB4827),
                              ),
                            ),
                            Text(
                              _isLoadingUser ? 'user@example.com' : (_userEmail ?? 'user@example.com'),
                              style: const TextStyle(
                                fontFamily: 'Rubik',
                                fontSize: 14,
                                color: Color(0xFF87837B),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "$_progressTimeFrame Progress 🌟",
                      style: const TextStyle(
                        fontFamily: 'Rubik',
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF251504),
                      ),
                    ),
                    DropdownButton<String>(
                      value: _progressTimeFrame,
                      icon: const Icon(Icons.arrow_drop_down, color: Color(0xFFDB4827)),
                      elevation: 16,
                      style: const TextStyle(
                        fontFamily: 'Rubik',
                        fontSize: 14,
                        color: Color(0xFF251504),
                      ),
                      underline: Container(
                        height: 2,
                        color: const Color(0xFFDB4827),
                      ),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _progressTimeFrame = newValue;
                          });
                          _fetchReportData();
                        }
                      },
                      items: <String>['Daily', 'Weekly', 'Monthly', 'Yearly']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Container(
                  height: 200,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: _isLoadingReport
                      ? const Center(child: CircularProgressIndicator(color: Color(0xFFDB4827)))
                      : BarChart(
                          BarChartData(
                            alignment: BarChartAlignment.spaceAround,
                            maxY: 100,
                            barTouchData: BarTouchData(
                              enabled: true,
                              touchTooltipData: BarTouchTooltipData(
                                tooltipRoundedRadius: 8,
                                getTooltipColor: (group) => const Color(0xFFDB4827).withOpacity(0.8),
                                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                  final category = ['Science', 'Math', 'Language', 'ESL'][group.x];
                                  return BarTooltipItem(
                                    '$category\n${rod.toY.toStringAsFixed(1)}%',
                                    const TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'Rubik',
                                      fontWeight: FontWeight.bold,
                                    ),
                                  );
                                },
                              ),
                            ),
                            titlesData: FlTitlesData(
                              show: true,
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, meta) {
                                    const style = TextStyle(
                                      color: Color(0xFF251504),
                                      fontFamily: 'Rubik',
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    );
                                    switch (value.toInt()) {
                                      case 0:
                                        return const Text('Science 🧪', style: style);
                                      case 1:
                                        return const Text('Math 🔢', style: style);
                                      case 2:
                                        return const Text('Language 📚', style: style);
                                      case 3:
                                        return const Text('ESL 🤟🏼', style: style);
                                      default:
                                        return const Text('', style: style);
                                    }
                                  },
                                ),
                              ),
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 40,
                                  getTitlesWidget: (value, meta) {
                                    if (value % 20 != 0) return const Text('');
                                    return Text(
                                      '${value.toInt()}%',
                                      style: const TextStyle(
                                        color: Color(0xFF251504),
                                        fontFamily: 'Rubik',
                                        fontSize: 12,
                                      ),
                                    );
                                  },
                                ),
                              ),
                              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            ),
                            gridData: FlGridData(
                              show: true,
                              drawVerticalLine: false,
                              getDrawingHorizontalLine: (value) {
                                return FlLine(
                                  color: Colors.grey.withOpacity(0.2),
                                  strokeWidth: 1,
                                );
                              },
                            ),
                            borderData: FlBorderData(show: false),
                            barGroups: [
                              BarChartGroupData(
                                x: 0,
                                barRods: [
                                  BarChartRodData(
                                    toY: _reportData['science']?['progress'] ?? 0.0,
                                    color: const Color(0xFF4CAF50),
                                    width: 30,
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                                    backDrawRodData: BackgroundBarChartRodData(
                                      show: true,
                                      toY: 100,
                                      color: Colors.grey.withOpacity(0.1),
                                    ),
                                  ),
                                ],
                              ),
                              BarChartGroupData(
                                x: 1,
                                barRods: [
                                  BarChartRodData(
                                    toY: _reportData['math']?['progress'] ?? 0.0,
                                    color: const Color(0xFF2196F3),
                                    width: 30,
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                                    backDrawRodData: BackgroundBarChartRodData(
                                      show: true,
                                      toY: 100,
                                      color: Colors.grey.withOpacity(0.1),
                                    ),
                                  ),
                                ],
                              ),
                              BarChartGroupData(
                                x: 2,
                                barRods: [
                                  BarChartRodData(
                                    toY: _reportData['language']?['progress'] ?? 0.0,
                                    color: const Color(0xFFFF9800),
                                    width: 30,
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                                    backDrawRodData: BackgroundBarChartRodData(
                                      show: true,
                                      toY: 100,
                                      color: Colors.grey.withOpacity(0.1),
                                    ),
                                  ),
                                ],
                              ),
                              BarChartGroupData(
                                x: 3,
                                barRods: [
                                  BarChartRodData(
                                    toY: _reportData['ESL']?['progress'] ?? 0.0,
                                    color: const Color(0xFF2196F3),
                                    width: 30,
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                                    backDrawRodData: BackgroundBarChartRodData(
                                      show: true,
                                      toY: 100,
                                      color: Colors.grey.withOpacity(0.1),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "$_screenTimeFrame Screen Time ⏰",
                      style: const TextStyle(
                        fontFamily: 'Rubik',
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF251504),
                      ),
                    ),
                    DropdownButton<String>(
                      value: _screenTimeFrame,
                      icon: const Icon(Icons.arrow_drop_down, color: Color(0xFFDB4827)),
                      elevation: 16,
                      style: const TextStyle(
                        fontFamily: 'Rubik',
                        fontSize: 14,
                        color: Color(0xFF251504),
                      ),
                      underline: Container(
                        height: 2,
                        color: const Color(0xFFDB4827),
                      ),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _screenTimeFrame = newValue;
                            _progressTimeFrame = newValue;
                          });
                          _fetchReportData();
                        }
                      },
                      items: <String>['Daily', 'Weekly', 'Monthly', 'Yearly']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Container(
                  height: 200,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: _isLoadingReport
                      ? const Center(child: CircularProgressIndicator(color: Color(0xFFDB4827)))
                      : BarChart(
                          BarChartData(
                            alignment: BarChartAlignment.spaceAround,
                            maxY: _getMaxYForTime(),
                            barTouchData: BarTouchData(
                              enabled: true,
                              touchTooltipData: BarTouchTooltipData(
                                tooltipRoundedRadius: 8,
                                getTooltipColor: (group) => const Color(0xFFDB4827).withOpacity(0.8),
                                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                  final category = ['Science', 'Math', 'Language', 'ESL'][group.x];
                                  return BarTooltipItem(
                                    '$category\n${rod.toY.toStringAsFixed(1)} min',
                                    const TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'Rubik',
                                      fontWeight: FontWeight.bold,
                                    ),
                                  );
                                },
                              ),
                            ),
                            titlesData: FlTitlesData(
                              show: true,
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, meta) {
                                    const style = TextStyle(
                                      color: Color(0xFF251504),
                                      fontFamily: 'Rubik',
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    );
                                    switch (value.toInt()) {
                                      case 0:
                                        return const Text('Science 🧪', style: style);
                                      case 1:
                                        return const Text('Math 🔢', style: style);
                                      case 2:
                                        return const Text('Language 📚', style: style);
                                      case 3:
                                        return const Text('ESL 🤟🏼', style: style);
                                      default:
                                        return const Text('', style: style);
                                    }
                                  },
                                ),
                              ),
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 40,
                                  getTitlesWidget: (value, meta) {
                                    if (value % (_getMaxYForTime() / 5).ceil() != 0) return const Text('');
                                    return Text(
                                      '${value.toInt()} min',
                                      style: const TextStyle(
                                        color: Color(0xFF251504),
                                        fontFamily: 'Rubik',
                                        fontSize: 12,
                                      ),
                                    );
                                  },
                                ),
                              ),
                              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            ),
                            gridData: FlGridData(
                              show: true,
                              drawVerticalLine: false,
                              getDrawingHorizontalLine: (value) {
                                return FlLine(
                                  color: Colors.grey.withOpacity(0.2),
                                  strokeWidth: 1,
                                );
                              },
                            ),
                            borderData: FlBorderData(show: false),
                            barGroups: [
                              BarChartGroupData(
                                x: 0,
                                barRods: [
                                  BarChartRodData(
                                    toY: (_reportData['science']?['time'] ?? 0.0) / 60.0,
                                    color: const Color(0xFF4CAF50),
                                    width: 30,
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                                    backDrawRodData: BackgroundBarChartRodData(
                                      show: true,
                                      toY: _getMaxYForTime(),
                                      color: Colors.grey.withOpacity(0.1),
                                    ),
                                  ),
                                ],
                              ),
                              BarChartGroupData(
                                x: 1,
                                barRods: [
                                  BarChartRodData(
                                    toY: (_reportData['math']?['time'] ?? 0.0) / 60.0,
                                    color: const Color(0xFF2196F3),
                                    width: 30,
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                                    backDrawRodData: BackgroundBarChartRodData(
                                      show: true,
                                      toY: _getMaxYForTime(),
                                      color: Colors.grey.withOpacity(0.1),
                                    ),
                                  ),
                                ],
                              ),
                              BarChartGroupData(
                                x: 2,
                                barRods: [
                                  BarChartRodData(
                                    toY: (_reportData['language']?['time'] ?? 0.0) / 60.0,
                                    color: const Color(0xFFFF9800),
                                    width: 30,
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                                    backDrawRodData: BackgroundBarChartRodData(
                                      show: true,
                                      toY: _getMaxYForTime(),
                                      color: Colors.grey.withOpacity(0.1),
                                    ),
                                  ),
                                ],
                              ),
                              BarChartGroupData(
                                x: 3,
                                barRods: [
                                  BarChartRodData(
                                    toY: (_reportData['ESL']?['time'] ?? 0.0) / 60.0,
                                    color: const Color(0xFF2196F3),
                                    width: 30,
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                                    backDrawRodData: BackgroundBarChartRodData(
                                      show: true,
                                      toY: _getMaxYForTime(),
                                      color: Colors.grey.withOpacity(0.1),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _changeAvatar,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFD18B),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      'Change Avatar',
                      style: TextStyle(
                        fontFamily: 'Rubik',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF251504),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      AppTranslations.setLocale(const Locale('am', 'ET'));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2CA2B0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      'Translate to Amharic',
                      style: TextStyle(
                        fontFamily: 'Rubik',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _logout,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFDB4827),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      'Logout',
                      style: TextStyle(
                        fontFamily: 'Rubik',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _deleteAccount,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      'Delete Account',
                      style: TextStyle(
                        fontFamily: 'Rubik',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}