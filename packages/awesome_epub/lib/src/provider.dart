import 'package:awesome_epub/src/epub_controller.dart';
import 'package:awesome_epub/src/epub_loader.dart';
import 'package:awesome_epub/src/epub_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final epubLoaderProvider = Provider<EPubLoader>((ref) {
  return DefaultEPubLoader();
});

final epubControllerProvider =
    StateNotifierProvider<EPubController, EPubState>((ref) {
  return EPubController();
});
