import 'dart:convert';
import 'dart:math';

import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const LotteryGeneratorApp());
}

class LotteryGeneratorApp extends StatelessWidget {
  const LotteryGeneratorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '6/49 Number Generator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.redAccent),
        useMaterial3: true,
      ),
      home: const NumberGeneratorScreen(),
    );
  }
}

class NumberGeneratorScreen extends StatefulWidget {
  const NumberGeneratorScreen({super.key});

  @override
  State<NumberGeneratorScreen> createState() => _NumberGeneratorScreenState();
}

class _NumberGeneratorScreenState extends State<NumberGeneratorScreen> {
  static const String _storageKey = 'draw_history';

  List<int> _numbers = [];
  List<List<int>> _history = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _loadHistoryAndInit();
  }

  Future<void> _loadHistoryAndInit() async {
    final prefs = await SharedPreferences.getInstance();
    final String? savedJson = prefs.getString(_storageKey);

    if (savedJson != null) {
      final List<dynamic> decoded = jsonDecode(savedJson);
      setState(() {
        _history = decoded.map((item) => List<int>.from(item)).toList();
      });
    }

    // Generate an initial draw without adding a duplicate if history already exists
    if (_history.isEmpty) {
      _generateNumbers();
    } else {
      setState(() {
        _numbers = List<int>.from(_history.first);
      });
    }
  }

  Future<void> _saveHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, jsonEncode(_history));
  }

  void _generateNumbers() {
    HapticFeedback.lightImpact();
    final Set<int> uniqueNumbers = {};

    while (uniqueNumbers.length < 6) {
      uniqueNumbers.add(_random.nextInt(49) + 1);
    }

    final sortedNumbers = uniqueNumbers.toList()..sort();

    setState(() {
      _numbers = sortedNumbers;
      _history.insert(0, sortedNumbers); // Add newest draw to the top
      if (_history.length > 50) {
        _history.removeLast(); // Keep up to 50 most recent draws
      }
    });

    _saveHistory();
  }

  void _copySet(List<int> numbers) {
    final formatted = numbers.join(', ');
    Clipboard.setData(ClipboardData(text: formatted));
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Copied: $formatted'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
    setState(() {
      _history.clear();
    });
  }

  Color _getBallColor(int number) {
    const redBalls = {
      1,
      2,
      7,
      8,
      12,
      13,
      18,
      19,
      23,
      24,
      29,
      30,
      34,
      35,
      40,
      45,
      46,
    };
    const blueBalls = {
      3,
      4,
      9,
      10,
      14,
      15,
      20,
      25,
      26,
      31,
      36,
      37,
      41,
      42,
      47,
      48,
    };

    if (redBalls.contains(number)) return Colors.red.shade600;
    if (blueBalls.contains(number)) return Colors.blue.shade600;
    return Colors.green.shade600;
  }

  Widget _buildBall(int number, {double size = 48, double fontSize = 18}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: _getBallColor(number),
        shape: BoxShape.circle,
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 3, offset: Offset(0, 2)),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        number.toString(),
        style: TextStyle(
          color: Colors.white,
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('6/49 Number Generator'),
        centerTitle: true,
        actions: [
          if (_numbers.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.copy),
              tooltip: 'Copy current numbers',
              onPressed: () => _copySet(_numbers),
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
        child: Column(
          children: [
            const Text(
              'Your Lucky Numbers',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            // Single-row ball display
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: _numbers.map((number) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5.0),
                    child: _buildBall(number),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 28),
            FilledButton.icon(
              onPressed: _generateNumbers,
              icon: const Icon(Icons.refresh),
              label: const Text(
                'Generate New Set',
                style: TextStyle(fontSize: 16),
              ),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 14,
                ),
              ),
            ),
            const SizedBox(height: 28),
            const Divider(),
            // History Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Saved History (${_history.length})',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (_history.isNotEmpty)
                  TextButton.icon(
                    onPressed: _clearHistory,
                    icon: const Icon(Icons.delete_outline, size: 18),
                    label: const Text('Clear'),
                  ),
              ],
            ),
            // Scrollable History List
            Expanded(
              child: _history.isEmpty
                  ? const Center(
                      child: Text(
                        'No saved draws yet.',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.separated(
                      itemCount: _history.length,
                      separatorBuilder: (_, _) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final draw = _history[index];
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 4,
                          ),
                          title: Row(
                            children: draw.map((number) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 6.0),
                                child: _buildBall(
                                  number,
                                  size: 32,
                                  fontSize: 13,
                                ),
                              );
                            }).toList(),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.copy, size: 20),
                            tooltip: 'Copy this set',
                            onPressed: () => _copySet(draw),
                          ),
                          onTap: () => _copySet(draw),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
