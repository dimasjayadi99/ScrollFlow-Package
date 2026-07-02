import 'package:flutter/material.dart';

Widget buildState({
  required bool isLoading,
  required Object? error,
  required bool isEmpty,
  required Widget Function() loading,
  required Widget Function(Object error) errorBuilder,
  required Widget Function() empty,
  required Widget Function() child,
}) {
  if (isLoading) {
    return loading();
  }

  if (error != null) {
    return errorBuilder(error);
  }

  if (isEmpty) {
    return empty();
  }

  return child();
}
