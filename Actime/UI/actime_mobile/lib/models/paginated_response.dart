/// Generic paginated response wrapper
class PaginatedResponse<T> {
  final List<T> data;
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;

  PaginatedResponse({
    required this.data,
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
  });

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    return PaginatedResponse<T>(
      data: (json['data'] as List<dynamic>)
          .map((item) => fromJsonT(item as Map<String, dynamic>))
          .toList(),
      currentPage: json['currentPage'] as int? ?? 1,
      lastPage: json['lastPage'] as int? ?? 1,
      perPage: json['perPage'] as int? ?? 10,
      total: json['total'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson(Map<String, dynamic> Function(T) toJsonT) {
    return {
      'data': data.map((item) => toJsonT(item)).toList(),
      'currentPage': currentPage,
      'lastPage': lastPage,
      'perPage': perPage,
      'total': total,
    };
  }

  /// Check if there are more pages
  bool get hasNextPage => currentPage < lastPage;

  /// Check if there are previous pages
  bool get hasPreviousPage => currentPage > 1;

  /// Check if this is the first page
  bool get isFirstPage => currentPage == 1;

  /// Check if this is the last page
  bool get isLastPage => currentPage == lastPage;

  /// Get the range of items being displayed
  String get displayRange {
    final start = (currentPage - 1) * perPage + 1;
    final end = start + data.length - 1;
    return '$start-$end od $total';
  }
}
