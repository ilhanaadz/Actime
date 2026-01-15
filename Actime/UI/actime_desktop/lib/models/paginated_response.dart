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
    final dataList = json['data'] as List? ?? [];

    return PaginatedResponse<T>(
      data: dataList.map((item) => fromJsonT(item as Map<String, dynamic>)).toList(),
      currentPage: json['current_page'] ?? json['currentPage'] ?? 1,
      lastPage: json['last_page'] ?? json['lastPage'] ?? 1,
      perPage: json['per_page'] ?? json['perPage'] ?? 10,
      total: json['total'] ?? dataList.length,
    );
  }

  bool get hasNextPage => currentPage < lastPage;
  bool get hasPreviousPage => currentPage > 1;
}
