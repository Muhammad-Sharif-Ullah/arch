import 'dart:developer';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:{{project_name}}/core/clients/network/api_response.dart';
import 'package:{{project_name}}/core/utils/paginaiton/paginated_response.dart';
import 'package:{{project_name}}/core/utils/paginaiton/pagination.dart';

part 'paginate_state_state.dart';

abstract class PaginateStateCubit<Q, P> extends Cubit<PaginateStateState<Q>> {
  final Future<Result<PaginatedResponse<Q>>> Function({required P payload})
      usecase;

  PaginateStateCubit({required this.usecase}) : super(PaginateInitial<Q>());

  Future<void> fetchInitialData({required P payload}) async {
    emit(PaginateLoading<Q>());
    final result = await usecase(payload: payload);
    result.fold((failure) => emit(PaginateFailure<Q>(failure)), (response) {
      if (response.data.isEmpty) {
        emit(PaginateEmpty<Q>());
      } else {
        emit(PaginateSuccess<Q>(response));
      }
    });
  }

  // get PaginateSuccess state pagination data
  Pagination? get currentPagination {
    if (state is PaginateSuccess<Q>) {
      final currentState = state as PaginateSuccess<Q>;
      return currentState.response.pagination;
    }
    return null;
  }

  Future<void> fetchMoreData({required P payload}) async {
    final p = currentPagination;
    log('Current Pagination: ${p.toString()}');
    if (state is PaginateSuccess<Q>) {
      final currentState = state as PaginateSuccess<Q>;
      if (currentState.response.pagination.page ==
          currentState.response.pagination.totalPage) {
        // No more data to fetch
        return;
      }
      emit(PaginateLoadingMore<Q>(currentState.response));
      final result = await usecase(payload: payload);
      result.fold(
        (failure) {
          emit(PaginateSuccess<Q>(currentState.response));
        },
        (response) {
          if (response.data.isEmpty) {
            emit(PaginateSuccess<Q>(currentState.response));
          } else {
            List<Q> updatedList = List<Q>.of(currentState.response.data);
            updatedList.addAll(response.data);
            final updatedResponse = PaginatedResponse<Q>(
              data: updatedList,
              pagination: response.pagination,
            );
            emit(PaginateSuccess<Q>(updatedResponse));
          }
        },
      );
    }
  }
}
