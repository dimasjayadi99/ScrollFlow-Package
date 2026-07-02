import 'package:flutter/material.dart';
import 'package:scrollflow/src/builders/scrollflow_state_builder.dart';
import 'package:scrollflow/src/controllers/scrollflow_mixin.dart';
import 'package:scrollflow/src/controllers/scrollflow_controller.dart';
import 'package:scrollflow/src/types/scrollflow_fetcher.dart';
import 'package:scrollflow/src/widgets/default_error_widget.dart';
import 'package:scrollflow/src/widgets/default_load_more_error_widget.dart';

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

class _ScrollFlowState<T> extends State<ScrollFlow<T>>
    with ScrollFlowMixin<T, ScrollFlow<T>> {
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
      loading: () {
        return widget.loadingWidget ??
            const Center(child: CircularProgressIndicator());
      },
      errorBuilder: (error) {
        return widget.errorBuilder?.call(error, retryInitial) ??
            DefaultErrorWidget(error: error, onRetry: retryInitial);
      },
      empty: () {
        return widget.emptyWidget ??
            const Center(child: Text('No data available'));
      },
      child: () {
        Widget list = ListView.separated(
          controller: controller,
          shrinkWrap: widget.shrinkWrap,
          physics: widget.enablePullToRefresh
              ? const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                )
              : widget.physics,
          padding: widget.padding,
          itemCount:
              items.length + (isLoadingMore || loadMoreError != null ? 1 : 0),
          separatorBuilder:
              widget.separatorBuilder ?? (_, _) => const SizedBox.shrink(),
          itemBuilder: (context, index) {
            if (index == items.length) {
              if (loadMoreError != null) {
                return DefaultLoadMoreErrorWidget(onRetry: retryLoadMore);
              }

              return widget.loadMoreWidget ??
                  const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: CircularProgressIndicator()),
                  );
            }

            return widget.itemBuilder(context, items[index]);
          },
        );
        if (widget.enablePullToRefresh) {
          list = RefreshIndicator(onRefresh: refresh, child: list);
        }
        return list;
      },
    );
  }
}
