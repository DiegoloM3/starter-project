import 'package:equatable/equatable.dart';

class ArticleLocation extends Equatable {
  final double latitude;
  final double longitude;
  final String? placeName;

  const ArticleLocation({
    required this.latitude,
    required this.longitude,
    this.placeName,
  });

  ArticleLocation copyWith({
    double? latitude,
    double? longitude,
    String? placeName,
  }) {
    return ArticleLocation(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      placeName: placeName ?? this.placeName,
    );
  }

  @override
  List<Object?> get props => [latitude, longitude, placeName];
}
