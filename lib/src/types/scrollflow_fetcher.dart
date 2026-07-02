import '../models/scrollflow_result.dart';

typedef ScrollFlowFetcher<T> = Future<ScrollFlowResult<T>> Function(int page);
