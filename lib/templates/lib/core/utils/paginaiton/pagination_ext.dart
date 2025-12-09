import 'package:{{project_name}}/core/clients/network/api_response.dart';
import 'package:{{project_name}}/core/utils/paginaiton/paginated_response.dart';
import 'package:{{project_name}}/core/utils/paginaiton/pagination.dart';

/// Extension to convert Result<List<T>> -> Result<PaginatedResponse<T>>
extension PaginatedResultMapper<T> on Result<List<T>> {
  Result<PaginatedResponse<T>> toPaginated() {
    return switch (this) {
      Success(data: final listData, pagination: final paginationMap) =>
        Result.success(
          data: PaginatedResponse<T>(
            data: listData,
            // Handle cases where pagination might be null safely
            pagination: Pagination.fromJson(paginationMap ?? {}),
          ),
        ),
      ResponseFailure(error: final e, statusCode: final s, message: final m) =>
        Result.failure(e, s, m),
    };
  }
}
