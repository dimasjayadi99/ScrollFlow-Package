import 'dart:convert';

import 'package:example/example_product_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:scrollflow/scrollflow.dart';

class GridFromApiExample extends StatefulWidget {
  const GridFromApiExample({super.key});

  @override
  State<GridFromApiExample> createState() => _GridFromApiExampleState();
}

class _GridFromApiExampleState extends State<GridFromApiExample> {
  final controller = ScrollFlowController<Product>();

  List<Product> products = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Products (${products.length})')),
      body: GridScrollFlow<Product>(
        controller: controller,
        enablePullToRefresh: true,
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.7,
        ),
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
        itemBuilder: (context, product) {
          return Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Image.network(
                    product.thumbnail,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '\$${product.price}',
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
        onItemsChanged: (items) {
          setState(() {
            products = items;
          });
        },
      ),
    );
  }
}
