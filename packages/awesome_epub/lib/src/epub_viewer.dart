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

          // const url =
          //     'https://nrzr.li/d3/y/1728246924/10000/e/zlib1/pilimi-zlib-11450000-11499999/11474960~/kAHQLtvIZ0yHAmfpLitQOg/The%20Search%20--%20Osho%2C%20Osho%20International%20Foundation%20%5BOsho%2C%20Osho%20--%202014%20--%20Osho%20Media%20International%20--%209780880503501%20--%200f1416b6919612519bab56c53c848afc%20--%20Anna%E2%80%99s%20Archive.epub';
          // Future<EpubBook> futureEpub = loader.getFromApi(url);

          Future<EpubBook> futureEpub = loader
              .getFromAsset('assets/New-Findings-on-Shirdi-Sai-Baba.epub');

          // Call the controller to load the EPUB
          await epubController.loadEpub(futureEpub);
        },
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
