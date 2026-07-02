import 'package:flutter/material.dart';

import '../types/scrollflow_fetcher.dart';

mixin ScrollFlowMixin<T, W extends StatefulWidget> on State<W> {
  ScrollFlowFetcher<T> get fetcher;

  double get loadMoreOffset;

  ValueChanged<List<T>>? get onItemsChanged;

  final ScrollController controller = ScrollController();

  final List<T> items = [];

  int page = 0;
  bool hasMore = true;
  bool isFetching = false;

  bool isInitialLoading = true;
  bool isLoadingMore = false;

  Object? initialError;
  Object? loadMoreError;

  Future<void> fetchNext() async {
    if (isFetching || !hasMore) return;
    isFetching = true;

    try {
      final result = await fetcher(page);
      if (!mounted) return;

      setState(() {
        items.addAll(result.items);
        hasMore = result.hasMore;
        page++;
        isInitialLoading = false;
        isLoadingMore = false;
        loadMoreError = null;
        initialError = null;
      });
      // Notify listeners with all loaded items.
      onItemsChanged?.call(List.unmodifiable(items));
    } catch (e) {
      if (!mounted) return;
      setState(() {
        if (page == 0) {
          initialError = e;
          isInitialLoading = false;
        } else {
          loadMoreError = e;
          isLoadingMore = false;
        }
      });
    } finally {
      isFetching = false;
    }
  }

  void onScroll() {
    if (!hasMore || isFetching || loadMoreError != null) return;

    final pos = controller.position;
    if (pos.extentAfter <= loadMoreOffset) {
      setState(() => isLoadingMore = true);
      fetchNext();
    }
  }

  void retryInitial() {
    setState(() {
      isInitialLoading = true;
      initialError = null;
    });
    fetchNext();
  }

  void retryLoadMore() {
    setState(() {
      loadMoreError = null;
      isLoadingMore = true;
    });
    fetchNext();
  }

  Future<void> refresh() async {
    page = 0;
    hasMore = true;
    isFetching = false;
    items.clear();

    initialError = null;
    loadMoreError = null;
    isLoadingMore = false;
    isInitialLoading = true;

    onItemsChanged?.call(const []);

    if (mounted) setState(() {});

    await fetchNext();
  }
}
