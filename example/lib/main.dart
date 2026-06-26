import 'package:example/basic_example.dart';
import 'package:example/fetch_from_api_example.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Builder(
        builder: (context) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const BasicExample()),
                      );
                    },
                    child: const Text('Basic Example'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const FromApiExample(),
                        ),
                      );
                    },
                    child: const Text('From API Example'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
