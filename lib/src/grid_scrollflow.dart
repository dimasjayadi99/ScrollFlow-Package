import 'package:flutter/material.dart';
import 'package:scrollflow/src/builders/scrollflow_state_builder.dart';
import 'package:scrollflow/src/controllers/scrollflow_mixin.dart';
import 'package:scrollflow/src/widgets/default_error_widget.dart';
import 'package:scrollflow/src/widgets/default_load_more_error_widget.dart';

import '../scrollflow.dart';
import 'types/scrollflow_fetcher.dart';

class GridScrollFlow<T> extends StatefulWidget {
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

  final SliverGridDelegate gridDelegate;

  const GridScrollFlow({
    super.key,
    this.controller,
    required this.fetcher,
    required this.itemBuilder,
    required this.gridDelegate,
    this.loadingWidget,
    this.errorBuilder,
    this.emptyWidget,
    this.loadMoreWidget,
    this.loadMoreOffset = 200,
    this.padding,
    this.onItemsChanged,
    this.shrinkWrap = false,
    this.physics,
    this.enablePullToRefresh = false,
  });

  @override
  State<GridScrollFlow<T>> createState() => _GridScrollFlowState<T>();
}

class _GridScrollFlowState<T> extends State<GridScrollFlow<T>>
    with ScrollFlowMixin<T, GridScrollFlow<T>> {
  @override
  ScrollFlowFetcher<T> get fetcher => widget.fetcher;

  @override
  double get loadMoreOffset => widget.loadMoreOffset;

  @override
  ValueChanged<List<T>>? get onItemsChanged => widget.onItemsChanged;

  @override
  void initState() {
    super.initState();
    widget.controller?.refresh = refresh;
    controller.addListener(onScroll);
    fetchNext();
  }

  @override
  void dispose() {
    widget.controller?.refresh = null;
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return buildState(
      isLoading: isInitialLoading,
      error: initialError,
      isEmpty: items.isEmpty,
      loading: () =>
          widget.loadingWidget ??
          const Center(child: CircularProgressIndicator()),
      errorBuilder: (error) =>
          widget.errorBuilder?.call(error, retryInitial) ??
          DefaultErrorWidget(error: error, onRetry: retryInitial),
      empty: () =>
          widget.emptyWidget ?? const Center(child: Text('No data available')),
      child: () {
        Widget grid = CustomScrollView(
          controller: controller,
          physics: widget.enablePullToRefresh
              ? const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                )
              : widget.physics,
          slivers: [
            SliverPadding(
              padding: widget.padding ?? EdgeInsets.zero,
              sliver: SliverGrid(
                gridDelegate: widget.gridDelegate,
                delegate: SliverChildBuilderDelegate((context, index) {
                  return widget.itemBuilder(context, items[index]);
                }, childCount: items.length),
              ),
            ),

            if (isLoadingMore)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),

            if (loadMoreError != null)
              SliverToBoxAdapter(
                child: DefaultLoadMoreErrorWidget(onRetry: retryLoadMore),
              ),
          ],
        );

        if (widget.enablePullToRefresh) {
          grid = RefreshIndicator(onRefresh: refresh, child: grid);
        }

        return grid;
      },
    );
  }
}
