// import 'package:awesome_epub/src/config/types.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:epubx/epubx.dart';

// class EPubController extends StateNotifier<EPubState> {
//   EPubController() : super(EPubState.initial());

//   Future<void> loadEpub(Future<EpubBook> futureEpub) async {
//     state = EPubState.loading;

//     try {
//       EpubBook epubBook = await futureEpub;
//       state = EPubState.loaded;
//       // You can store the loaded book if needed here
//       // Example: this.loadedEpubBook = epubBook;
//     } catch (e) {
//       // Handle the error and update the state
//       setError(e.toString());
//     }
//   }

//   void setError(String errorMessage) {
//     state = EPubState.error;
//     print("[EPubController]: Error occurred while loading EPUB");
//     print("Error Message: $errorMessage");
//     // You can store the error message if needed for UI display
//     // Example: this.errorMessage = errorMessage;
//   }
// }

import 'package:awesome_epub/src/epub_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:epubx/epubx.dart';

class EPubController extends StateNotifier<EPubState> {
  EPubController() : super(EPubState.initial());

  Future<void> loadEpub(Future<EpubBook> futureEpub) async {
    state = EPubState.loading(); // Set loading state

    try {
      EpubBook epubBook = await futureEpub;
      state = EPubState.loaded(epubBook); // Set loaded state with the epubBook
    } catch (e) {
      state =
          EPubState.error(e.toString()); // Set error state with error message
    }
  }
}
