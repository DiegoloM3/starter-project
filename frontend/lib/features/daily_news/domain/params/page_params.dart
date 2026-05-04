import 'package:equatable/equatable.dart';

class PageParams extends Equatable {
  final int page;
  final int pageSize;

  const PageParams({this.page = 1, this.pageSize = 20});

  @override
  List<Object?> get props => [page, pageSize];
}
