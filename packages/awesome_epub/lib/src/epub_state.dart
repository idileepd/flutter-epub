import 'package:epub_plus/epub_plus.dart';

class EPubState {
  final bool isLoading;
  final bool hasError;
  final String? errorMessage;
  final EpubBook? epubBook;

  EPubState({
    required this.isLoading,
    required this.hasError,
    this.errorMessage,
    this.epubBook,
  });

  // Factory methods for convenience
  factory EPubState.initial() {
    return EPubState(
      isLoading: false,
      hasError: false,
      errorMessage: null,
      epubBook: null,
    );
  }

  factory EPubState.loading() {
    return EPubState(
      isLoading: true,
      hasError: false,
      errorMessage: null,
      epubBook: null,
    );
  }

  factory EPubState.loaded(EpubBook epubBook) {
    return EPubState(
      isLoading: false,
      hasError: false,
      errorMessage: null,
      epubBook: epubBook,
    );
  }

  factory EPubState.error(String errorMessage) {
    return EPubState(
      isLoading: false,
      hasError: true,
      errorMessage: errorMessage,
      epubBook: null,
    );
  }
}
