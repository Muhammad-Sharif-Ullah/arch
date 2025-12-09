part of 'paginate_state_cubit.dart';

sealed class PaginateStateState<T> extends Equatable {
  const PaginateStateState();

  @override
  List<Object?> get props => [];
}

class PaginateInitial<T> extends PaginateStateState<T> {
  const PaginateInitial();
}

class PaginateLoading<T> extends PaginateStateState<T> {
  const PaginateLoading();
}

class PaginateSuccess<T> extends PaginateStateState<T> {
  final PaginatedResponse<T> response;
  const PaginateSuccess(this.response);

  @override
  List<Object?> get props => [response];
}

class PaginateFailure<T> extends PaginateStateState<T> {
  final ResponseFailure<PaginatedResponse<T>> failure;
  const PaginateFailure(this.failure);

  @override
  List<Object?> get props => [failure];
}

class PaginateEmpty<T> extends PaginateStateState<T> {
  const PaginateEmpty();
}

class PaginateLoadingMore<T> extends PaginateStateState<T> {
  final PaginatedResponse<T> previousResponse;
  const PaginateLoadingMore(this.previousResponse);

  @override
  List<Object?> get props => [previousResponse];
}
