class PageParams {
  final int page;
  final int size;
  final int? total;

  PageParams({
    required this.page,
    this.size = 10,
    this.total,
  });
}
