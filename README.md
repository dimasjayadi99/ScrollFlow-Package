
# ScrollFlow

A lightweight and customizable infinite scrolling widget for Flutter. ScrollFlow helps you implement infinite scrolling with minimal boilerplate. Simply provide a fetcher to load paginated data and an itemBuilder to display each item. The package automatically handles loading, pagination, empty state, error state, and load-more behavior.

![Example](examples.gif)

## Features

- 🚀 Automatic infinite scrolling
- 📄 Simple page-based pagination
- 🎨 Custom loading, error, and empty widgets
- 🔄 Built-in retry support
- 🔃 Optional pull-to-refresh
- 🎮 Programmatic refresh with ScrollFlowController
- 📱 Works with any data type using generics
- ⚡ Lightweight and easy to use
- 🔲 Supports both ListView and GridView layouts

## Installation

Add the dependency to your pubspec.yaml:

dependencies: `scrollflow: ^0.1.0`

Then run:

```bash
  flutter pub get
```
    
## Basic Usage

```javascript
ScrollFlow<int>(
  fetcher: (int page) async {
    await Future.delayed(const Duration(seconds: 1));
    final items = List.generate(20, (index) => page * 20 + index);
    return ScrollFlowResult(items: items, hasMore: page < 4);
  },
  itemBuilder: (context, item) {
    return ListTile(title: Text('Item $item'));
  },
)
```


## Fetching Data From API

```javascript
/// Controller for interacting with the ScrollFlow widget.
final controller = ScrollFlowController<Product>();

// Holds all items that have been loaded by ScrollFlow.
List<Product> products = [];

ScrollFlow<Product>(
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
    child: yourWidget(),
  ),
  // Receive all loaded items whenever the list changes.
  onItemsChanged: (value) {
    setState(() {
      products = value;
    });
  },
),
```

## Grid Usage

Simply use GridScrollFlow with a SliverGridDelegate.

```
GridScrollFlow<Product>(
  ...
  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 2,
    crossAxisSpacing: 16,
    mainAxisSpacing: 16,
    childAspectRatio: 0.7,
  ),
  fetcher: (page) async {
    ...
  },
  itemBuilder: (context, product) {
    return yourWidget()
  },
  onItemsChanged: (items) {
    setState(() {
      products = items;
    });
  },
),
```

## Refresh Programmatically

You can refresh the list at any time using a `ScrollFlowController`.

```dart
final controller = ScrollFlowController<Product>();

ElevatedButton(
  onPressed: () async {
    await controller.refresh();
  },
  child: const Text('Refresh'),
);

ScrollFlow<Product>(
  controller: controller,
  fetcher: ...,
  itemBuilder: ...,
);
```

## Custom Loading Widget

```
ScrollFlow<Product>( 
  loadingWidget: const Center( 
    child: CircularProgressIndicator(), 
  ), 
  fetcher: ..., 
  itemBuilder: ..., 
);
```
## Custom Empty Widget

```
ScrollFlow<Product>( 
  emptyWidget: const Center( 
    child: Text('No products found'), 
  ), 
  fetcher: ..., 
  itemBuilder: ..., 
);
```
## Custom Error Widget

```
ScrollFlow<Product>( 
  errorBuilder: (error, retry) { 
    return Center( child: ElevatedButton( 
        onPressed: retry, 
        child: const Text('Retry'), 
      ), 
    ); 
  }, 
  fetcher: ..., 
  itemBuilder: ..., 
);
```
## Custom Load More Indicator

```
ScrollFlow<Product>( 
  loadMoreWidget: const Padding( 
    padding: EdgeInsets.all(24), 
    child: CircularProgressIndicator(), 
  ), 
  fetcher: ..., 
  itemBuilder: ..., 
);
```
## API Reference

| Parameter | Description                |
| :-------- | :------------------------- |
| `controller` | Controls the ScrollFlow instance programmatically (e.g. refresh). |
| `fetcher` | Loads a page of data. |
| `itemBuilder` | Builds each list item. |
| `loadingWidget` | Widget displayed during the initial loading state. |
| `errorBuilder` | Widget displayed when the initial request fails. |
| `emptyWidget` | Widget displayed when no data is available. |
| `loadMoreWidget` | Widget displayed while loading additional items. |
| `loadMoreOffset` | Distance from the bottom before loading more data. |
| `padding` | Padding applied to the ListView. |
| `separatorBuilder` | Builds separators between items. |
| `onItemsChanged` | Callback invoked when the displayed items are updated. |
| `physics` | Custom scroll physics for the internal ListView. |
| `shrinkWrap` | Whether the scroll view should size itself to its contents. |
| `enablePullToRefresh` | Enables pull-to-refresh using a built-in RefreshIndicator. |
| `gridDelegate` | Configures the layout of GridScrollFlow. (Only available in GridScrollFlow) |

## Articles
- [Introducing ScrollFlow: Build Infinite Scroll in Flutter in Minutes.](https://medium.com/@dimasjayadi7/introducing-scrollflow-build-infinite-scroll-in-flutter-in-minutes-89af1e81367b?sharedUserId=dimasjayadi7)

## Example

A complete runnable example is available in the `example/` directory.
## License

[MIT](https://choosealicense.com/licenses/mit/)

