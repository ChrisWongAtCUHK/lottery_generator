import 'dart:math';

import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';

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
  List<int> _numbers = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _generateNumbers(); // Generate an initial set on startup
  }

  void _generateNumbers() {
    HapticFeedback.lightImpact(); // Tactile feedback on tap
    final Set<int> uniqueNumbers = {};

    // Keep generating until we have 6 unique numbers
    while (uniqueNumbers.length < 6) {
      // nextInt(49) generates 0..48, so + 1 shifts it to 1..49
      uniqueNumbers.add(_random.nextInt(49) + 1);
    }

    setState(() {
      _numbers = uniqueNumbers.toList()..sort();
    });
  }

  // Optional: Color-code balls similar to Mark Six rules
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('6/49 Number Generator'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Your Lucky Numbers',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 32),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: _numbers.map((number) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5.0),
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: _getBallColor(number),
                          shape: BoxShape.circle,
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          number.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 48),
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
            ],
          ),
        ),
      ),
    );
  }
}
