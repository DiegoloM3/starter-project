enum RemoteArticleStatus {
  createdArticleSuccess,
  genericError,
  none;

  bool get isCreatedArticleSuccess =>
      this == RemoteArticleStatus.createdArticleSuccess;
  bool get isGenericError => this == RemoteArticleStatus.genericError;
  bool get isNone => this == RemoteArticleStatus.none;
}
