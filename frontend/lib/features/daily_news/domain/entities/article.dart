import 'package:equatable/equatable.dart';

<<<<<<< HEAD
class ArticleEntity extends Equatable{
  final int ? id;
  final String ? author;
  final String ? title;
  final String ? description;
  final String ? url;
  final String ? urlToImage;
  final String ? publishedAt;
  final String ? content;
=======
class ArticleEntity extends Equatable {
  final int? id;
  final String? author;
  final String title;
  final String? description;
  final String url;
  final String? urlToImage;
  final String? publishedAt;
  final String? content;
>>>>>>> fbce432 (Finish PR (project setup))

  const ArticleEntity({
    this.id,
    this.author,
<<<<<<< HEAD
    this.title,
    this.description,
    this.url,
=======
    required this.title,
    this.description,
    required this.url,
>>>>>>> fbce432 (Finish PR (project setup))
    this.urlToImage,
    this.publishedAt,
    this.content,
  });

  @override
<<<<<<< HEAD
  List < Object ? > get props {
    return [
      id,
      author,
      title,
      description,
      url,
      urlToImage,
      publishedAt,
      content,
    ];
  }
}
=======
  List<Object?> get props => [
        id, author, title, description,
        url, urlToImage, publishedAt, content,
      ];
}
>>>>>>> fbce432 (Finish PR (project setup))
