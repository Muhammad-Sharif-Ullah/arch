sealed class Result<T> {
  const Result();

  factory Result.success({required T data, Map<String, dynamic>? pagination}) =
      Success<T>;
  factory Result.failure(
    String error, [
    int? statusCode,
    Map<String, dynamic>? message,
  ]) = ResponseFailure<T>;

  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is ResponseFailure<T>;

  /// Dartz-like fold
  R fold<R>(
    R Function(ResponseFailure<T> failure) onFailure,
    R Function(T data) onSuccess,
  ) {
    if (this is Success<T>) {
      return onSuccess((this as Success<T>).data);
    } else {
      return onFailure(this as ResponseFailure<T>);
    }
  }

  // when
  R when<R>({
    required R Function(ResponseFailure<T> failure) onFailure,
    required R Function(T data) onSuccess,
  }) {
    if (this is Success<T>) {
      return onSuccess((this as Success<T>).data);
    } else {
      return onFailure(this as ResponseFailure<T>);
    }
  }
}

final class Success<T> extends Result<T> {
  final T data;
  final Map<String, dynamic>? pagination;
  const Success({required this.data, this.pagination});
}

final class ResponseFailure<T> extends Result<T> {
  final String error;
  final int? statusCode;
  final Map<String, dynamic>? message;
  const ResponseFailure(this.error, [this.statusCode, this.message]);
}

class Nullable<T> {
  final T? value;

  const Nullable(this.value);

  factory Nullable.fromJson(dynamic json, T Function(dynamic json) fromJsonT) {
    if (json == null) return Nullable<T>(null);
    return Nullable<T>(fromJsonT(json));
  }

  Object? toJson(Object? Function(T? value) toJsonT) {
    return value == null ? null : toJsonT(value);
  }

  @override
  String toString() => 'Nullable($value)';

  @override
  bool operator ==(Object other) =>
      other is Nullable<T> && other.value == value;

  @override
  int get hashCode => value.hashCode;
}
