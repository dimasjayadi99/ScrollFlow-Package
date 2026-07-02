class ScrollFlowController<T> {
  Future<void> Function()? refresh;

  Future<void> onRefresh() async {
    await refresh?.call();
  }
}
