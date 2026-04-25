import 'package:json_annotation/json_annotation.dart';

part 'source_model.g.dart';

/// `articles[].source` block in NewsAPI's `/top-headlines` response.
///
/// Kept as a standalone `@JsonSerializable` model so Retrofit can deserialise
/// the nested object directly. It is marked `@ignore` on `ArticleModel` so
/// Floor skips persistence — saved articles expose the flattened fields via
/// the domain entity instead.
@JsonSerializable()
class SourceModel {
  const SourceModel({this.id, this.name});

  factory SourceModel.fromJson(Map<String, dynamic> json) =>
      _$SourceModelFromJson(json);

  final String? id;
  final String? name;

  Map<String, dynamic> toJson() => _$SourceModelToJson(this);
}
