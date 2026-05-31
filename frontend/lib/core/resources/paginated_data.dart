/// A mixin that provides a standard pagination contract for data models.
///
/// Apply this mixin to any model (remote or local) that represents a paginated
/// response, so both [data_sources/remote] and [data_sources/local] can share
/// the same interface without cross-importing between data sources.
mixin PaginatedData<T> {
  int get offset;

  int get limit;

  int get total;

  int get count;

  List<T> get results;

  bool get hasMore => offset + count < total;
}
