import 'package:flutter/material.dart';
import 'package:scrollflow/scrollflow.dart';

class BasicExample extends StatefulWidget {
  const BasicExample({super.key});

  @override
  State<BasicExample> createState() => _BasicExampleState();
}

class _BasicExampleState extends State<BasicExample> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ScrollFlow Example')),
      body: ScrollFlow<int>(
        fetcher: (int page) async {
          await Future.delayed(const Duration(seconds: 1));
          final items = List.generate(20, (index) => page * 20 + index);
          return ScrollFlowResult(items: items, hasMore: page < 4);
        },
        itemBuilder: (context, item) {
          return ListTile(title: Text('Item $item'));
        },
      ),
    );
  }
}
