/// Generic paginated response wrapper
/// Maps to backend PagedResult<T>
class PaginatedResponse<T> {
  final List<T> items;
  final int? totalCount;
  final int page;
  final int pageSize;

  PaginatedResponse({
    List<T>? items,
    List<T>? data,
    int? totalCount,
    int? total,
    int? page,
    int? currentPage,
    int? pageSize,
    int? perPage,
    int? lastPage,
  }) : items = items ?? data ?? [],
       totalCount = totalCount ?? total,
       page = page ?? currentPage ?? 1,
       pageSize = pageSize ?? perPage ?? 10;

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

  Map<String, dynamic> toJson(Map<String, dynamic> Function(T) toJsonT) {
    return {
      'Items': items.map((item) => toJsonT(item)).toList(),
      'TotalCount': totalCount,
      'Page': page,
      'PageSize': pageSize,
    };
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

  /// Get the range of items being displayed
  String get displayRange {
    if (items.isEmpty) return '0 od ${totalCount ?? 0}';
    final start = (page - 1) * pageSize + 1;
    final end = start + items.length - 1;
    return '$start-$end od ${totalCount ?? items.length}';
  }

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
