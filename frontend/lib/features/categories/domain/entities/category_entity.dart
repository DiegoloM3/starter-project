import 'package:equatable/equatable.dart';

class CategoryEntity extends Equatable {
  final String id;
  final String name;
  final String description;
  final String iconUrl;

  const CategoryEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.iconUrl,
  });

  @override
  List<Object?> get props => [id, name, description, iconUrl];
}
