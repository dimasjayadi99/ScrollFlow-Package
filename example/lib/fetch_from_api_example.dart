import 'dart:convert';
import 'package:example/example_product_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:scrollflow/scrollflow.dart';

class FromApiExample extends StatefulWidget {
  const FromApiExample({super.key});

  @override
  State<FromApiExample> createState() => _FromApiExampleState();
}

class _FromApiExampleState extends State<FromApiExample> {
  /// Controller for interacting with the ScrollFlow widget.
  final controller = ScrollFlowController<Product>();

  // Holds all items that have been loaded by ScrollFlow.
  List<Product> products = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Products ${products.length}')),
      body: ScrollFlow<Product>(
        controller: controller,
        enablePullToRefresh: true,
        fetcher: (page) async {
          final res = await http.get(
            Uri.parse(
              'https://dummyjson.com/products?limit=20&skip=${page * 20}',
            ),
          );
          final data = jsonDecode(res.body);
          final items = (data['products'] as List<dynamic>)
              .cast<Map<String, dynamic>>()
              .map(Product.fromJson)
              .toList();

          return ScrollFlowResult(
            items: items,
            hasMore: (page + 1) * 20 < (data['total'] as int),
          );
        },
        itemBuilder: (context, product) => Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            leading: Image.network(
              product.thumbnail,
              width: 60,
              fit: BoxFit.cover,
            ),
            title: Text(product.title),
            subtitle: Text('\$${product.price}'),
            onTap: () {
              debugPrint('Tapped on ${product.title}');
            },
          ),
        ),
        // Receive all loaded items whenever the list changes.
        onItemsChanged: (value) {
          setState(() {
            products = value;
          });
        },
      ),
    );
  }
}
