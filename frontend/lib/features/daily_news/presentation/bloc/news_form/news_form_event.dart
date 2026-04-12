import 'dart:io';

import 'package:news_app_clean_architecture/features/daily_news/domain/entities/news_section.dart';

sealed class NewsFormEvent {
  const NewsFormEvent();
}

class NewsFormTitleChanged extends NewsFormEvent {
  final String title;

  const NewsFormTitleChanged(this.title);
}

class NewsFormBodyChanged extends NewsFormEvent {
  final String body;

  const NewsFormBodyChanged(this.body);
}

class NewsFormSectionChanged extends NewsFormEvent {
  final NewsSection section;

  const NewsFormSectionChanged(this.section);
}

class NewsFormImageAdded extends NewsFormEvent {
  final File image;

  const NewsFormImageAdded(this.image);
}

class NewsFormImageRemoved extends NewsFormEvent {
  final int index;

  const NewsFormImageRemoved(this.index);
}

class NewsFormAuthorChanged extends NewsFormEvent {
  final String author;

  const NewsFormAuthorChanged(this.author);
}

class NewsFormSubmitted extends NewsFormEvent {
  const NewsFormSubmitted();
}

class NewsFormSavedAsDraft extends NewsFormEvent {
  const NewsFormSavedAsDraft();
}

class NewsFormDeleted extends NewsFormEvent {
  const NewsFormDeleted();
}
