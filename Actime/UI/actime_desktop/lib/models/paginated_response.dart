/// Generic paginated response wrapper
/// Maps to backend PagedResult<T>
class PaginatedResponse<T> {
  final List<T> items;
  final int? totalCount;
  final int page;
  final int pageSize;

  PaginatedResponse({
    required this.items,
    this.totalCount,
    this.page = 1,
    this.pageSize = 10,
  });

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    // Handle backend response format (Items array or direct array)
    List<dynamic> itemsList;
    if (json['Items'] != null) {
      itemsList = json['Items'] as List<dynamic>;
    } else if (json['items'] != null) {
      itemsList = json['items'] as List<dynamic>;
    } else if (json['data'] != null) {
      // Legacy format support
      itemsList = json['data'] as List<dynamic>;
    } else {
      itemsList = [];
    }

    return PaginatedResponse<T>(
      items: itemsList
          .map((item) => fromJsonT(item as Map<String, dynamic>))
          .toList(),
      totalCount: json['TotalCount'] as int? ?? json['totalCount'] as int? ?? json['total'] as int?,
      page: json['Page'] as int? ?? json['page'] as int? ?? json['currentPage'] as int? ?? 1,
      pageSize: json['PageSize'] as int? ?? json['pageSize'] as int? ?? json['perPage'] as int? ?? 10,
    );
  }

  /// Create from a simple list response (no pagination metadata)
  factory PaginatedResponse.fromList(
    List<dynamic> list,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    final items = list
        .map((item) => fromJsonT(item as Map<String, dynamic>))
        .toList();
    return PaginatedResponse<T>(
      items: items,
      totalCount: items.length,
      page: 1,
      pageSize: items.length,
    );
  }

  /// Calculate total pages
  int get totalPages {
    if (totalCount == null || totalCount == 0) return 1;
    return (totalCount! / pageSize).ceil();
  }

  /// Check if there are more pages
  bool get hasNextPage => page < totalPages;

  /// Check if there are previous pages
  bool get hasPreviousPage => page > 1;

  /// Check if this is the first page
  bool get isFirstPage => page == 1;

  /// Check if this is the last page
  bool get isLastPage => page >= totalPages;

  /// Check if list is empty
  bool get isEmpty => items.isEmpty;

  /// Check if list is not empty
  bool get isNotEmpty => items.isNotEmpty;

  /// Get items count
  int get length => items.length;

  // Legacy getters for backwards compatibility
  List<T> get data => items;
  int get currentPage => page;
  int get lastPage => totalPages;
  int get perPage => pageSize;
  int get total => totalCount ?? items.length;
}
