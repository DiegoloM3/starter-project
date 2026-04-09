enum LocalArticleStatus {
  savedSuccess,
  deletedSuccess,
  genericError,
  none;

  bool get isSavedSucess => this == LocalArticleStatus.savedSuccess;
  bool get isDeletedSucess => this == LocalArticleStatus.deletedSuccess;
  bool get isGenericError => this == LocalArticleStatus.genericError;
  bool get isNone => this == LocalArticleStatus.none;
}
