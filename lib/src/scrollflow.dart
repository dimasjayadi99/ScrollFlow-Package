import 'package:flutter/material.dart';

class ScrollFlowResult<T> {
  final List<T> items;
  final bool hasMore;

  const ScrollFlowResult({required this.items, required this.hasMore});
}

typedef ScrollFlowFetcher<T> = Future<ScrollFlowResult<T>> Function(int page);

class ScrollFlow<T> extends StatefulWidget {
  /// Controller for interacting with the ScrollFlow widget.
  final ScrollFlowController<T>? controller;

  /// The first page starts at 0.
  final ScrollFlowFetcher<T> fetcher;

  /// Builds a widget for each item.
  final Widget Function(BuildContext context, T item) itemBuilder;

  /// Widget displayed while loading the first page.
  final Widget? loadingWidget;

  /// Builds a widget displayed when the initial load fails.
  /// The provided callback can be used to retry the request.
  final Widget Function(Object error, VoidCallback retry)? errorBuilder;

  /// Widget displayed when no data is available.
  final Widget? emptyWidget;

  /// Widget displayed while loading additional pages.
  final Widget? loadMoreWidget;

  /// Distance from the bottom of the list before triggering
  /// the next page request.
  /// Defaults to 200 pixels.
  final double loadMoreOffset;

  /// Padding applied to the ListView.
  final EdgeInsetsGeometry? padding;

  /// Builds a separator widget between list items.
  final Widget Function(BuildContext, int)? separatorBuilder;

  /// Called whenever the internal items list changes.
  /// Returns all loaded items.
  /// Useful when you need to access the entire list outside of ScrollFlow,
  final ValueChanged<List<T>>? onItemsChanged;

  /// Whether the list should shrink-wrap its contents.
  final bool shrinkWrap;

  /// Scroll physics applied to the internal ListView.
  final ScrollPhysics? physics;

  /// Enables pull-to-refresh using a built-in RefreshIndicator.
  final bool enablePullToRefresh;

  const ScrollFlow({
    super.key,
    this.controller,
    required this.fetcher,
    required this.itemBuilder,
    this.loadingWidget,
    this.errorBuilder,
    this.emptyWidget,
    this.loadMoreWidget,
    this.loadMoreOffset = 200,
    this.padding,
    this.separatorBuilder,
    this.onItemsChanged,
    this.shrinkWrap = false,
    this.physics,
    this.enablePullToRefresh = false,
  });

  @override
  State<ScrollFlow<T>> createState() => _ScrollFlowState<T>();
}

class _ScrollFlowState<T> extends State<ScrollFlow<T>> {
  final ScrollController _controller = ScrollController();
  final List<T> _items = [];

  int _page = 0;
  bool _hasMore = true;
  bool _isFetching = false;

  // Status initial load
  bool _isInitialLoading = true;
  Object? _initialError;

  // Status load-more
  bool _isLoadingMore = false;
  Object? _loadMoreError;

  @override
  void initState() {
    super.initState();
    widget.controller?._refresh = _refresh;
    _controller.addListener(_onScroll);
    _fetchNext();
  }

  @override
  void dispose() {
    widget.controller?._refresh = null;
    _controller.dispose();
    super.dispose();
  }

  Future<void> _fetchNext() async {
    if (_isFetching || !_hasMore) return;
    _isFetching = true;

    try {
      final result = await widget.fetcher(_page);
      if (!mounted) return;

      setState(() {
        _items.addAll(result.items);
        _hasMore = result.hasMore;
        _page++;
        _isInitialLoading = false;
        _isLoadingMore = false;
        _loadMoreError = null;
        _initialError = null;
      });
      // Notify listeners with all loaded items.
      widget.onItemsChanged?.call(List.unmodifiable(_items));
    } catch (e) {
      if (!mounted) return;
      setState(() {
        if (_page == 0) {
          _initialError = e;
          _isInitialLoading = false;
        } else {
          _loadMoreError = e;
          _isLoadingMore = false;
        }
      });
    } finally {
      _isFetching = false;
    }
  }

  void _onScroll() {
    if (!_hasMore || _isFetching || _loadMoreError != null) return;

    final pos = _controller.position;
    if (pos.extentAfter <= widget.loadMoreOffset) {
      setState(() => _isLoadingMore = true);
      _fetchNext();
    }
  }

  void _retryInitial() {
    setState(() {
      _isInitialLoading = true;
      _initialError = null;
    });
    _fetchNext();
  }

  void _retryLoadMore() {
    setState(() {
      _loadMoreError = null;
      _isLoadingMore = true;
    });
    _fetchNext();
  }

  Future<void> _refresh() async {
    _page = 0;
    _hasMore = true;
    _isFetching = false;
    _items.clear();

    _initialError = null;
    _loadMoreError = null;
    _isLoadingMore = false;
    _isInitialLoading = true;

    widget.onItemsChanged?.call(const []);

    if (mounted) setState(() {});

    await _fetchNext();
  }

  @override
  Widget build(BuildContext context) {
    // ── Initial loading
    if (_isInitialLoading) {
      return widget.loadingWidget ??
          const Center(child: CircularProgressIndicator());
    }

    // ── Initial error
    if (_initialError != null) {
      return widget.errorBuilder?.call(_initialError!, _retryInitial) ??
          _DefaultErrorWidget(error: _initialError!, onRetry: _retryInitial);
    }

    // ── Empty
    if (_items.isEmpty) {
      return widget.emptyWidget ??
          const Center(child: Text('No data available'));
    }

    // ── List
    final itemCount =
        _items.length + (_isLoadingMore || _loadMoreError != null ? 1 : 0);

    Widget list = ListView.separated(
      controller: _controller,
      shrinkWrap: widget.shrinkWrap,
      physics: widget.enablePullToRefresh
          ? const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics())
          : widget.physics,
      padding: widget.padding,
      itemCount: itemCount,
      separatorBuilder:
          widget.separatorBuilder ?? (_, _) => const SizedBox.shrink(),
      itemBuilder: (context, index) {
        // Footer: loader atau error load-more
        if (index == _items.length) {
          if (_loadMoreError != null) {
            return _DefaultLoadMoreErrorWidget(onRetry: _retryLoadMore);
          }
          return widget.loadMoreWidget ??
              const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()),
              );
        }

        return widget.itemBuilder(context, _items[index]);
      },
    );

    if (widget.enablePullToRefresh) {
      return RefreshIndicator(onRefresh: _refresh, child: list);
    }

    return list;
  }
}

class ScrollFlowController<T> {
  Future<void> Function()? _refresh;

  Future<void> refresh() async {
    await _refresh?.call();
  }
}

// ───────────── Default widgets ─────────────
class _DefaultErrorWidget extends StatelessWidget {
  final Object error;
  final VoidCallback onRetry;

  const _DefaultErrorWidget({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 12),
          Text(error.toString()),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}

class _DefaultLoadMoreErrorWidget extends StatelessWidget {
  final VoidCallback onRetry;

  const _DefaultLoadMoreErrorWidget({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Failed to load more'),
          const SizedBox(width: 12),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}
