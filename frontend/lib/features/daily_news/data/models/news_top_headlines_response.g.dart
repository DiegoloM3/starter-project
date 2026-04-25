// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'news_top_headlines_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NewsTopHeadlinesResponse _$NewsTopHeadlinesResponseFromJson(
        Map<String, dynamic> json) =>
    NewsTopHeadlinesResponse(
      status: json['status'] as String? ?? '',
      totalResults: (json['totalResults'] as num?)?.toInt() ?? 0,
      articles: (json['articles'] as List<dynamic>?)
              ?.map((e) => ArticleModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
