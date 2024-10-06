import 'package:awesome_epub/src/epub_content.dart';
import 'package:awesome_epub/src/provider.dart';
import 'package:epub_plus/epub_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EpubViewer extends ConsumerWidget {
  const EpubViewer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final epubState = ref.watch(epubControllerProvider);
    final epubController = ref.read(epubControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('EPUB Viewer'),
      ),
      body: Center(
        child: () {
          if (epubState.isLoading) {
            return const CircularProgressIndicator();
          } else if (epubState.hasError) {
            return Text('Error loading EPUB: ${epubState.errorMessage}');
          } else if (epubState.epubBook != null) {
            return EpubContentWidget(epubBook: epubState.epubBook!);
          } else {
            return const Text('No EPUB loaded.');
          }
        }(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Example: Load EPUB from an asset
          final loader = ref.read(epubLoaderProvider);
          // Future<EpubBook> futureEpub =
          //     loader.getFromAsset('assets/sample.epub');
          Future<EpubBook> futureEpub = loader.getFromApi(
              'https://github.com/daisy/epub-accessibility-tests/releases/download/fundamental-2.0/Fundamental-Accessibility-Tests-Basic-Functionality-v2.0.0.epub');

          // Call the controller to load the EPUB
          await epubController.loadEpub(futureEpub);
        },
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
