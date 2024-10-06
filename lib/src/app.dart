import 'package:flutter/material.dart';
import 'package:epub_awesome/epub_awesome.dart';
import 'package:internet_file/internet_file.dart';

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  Future<EpubController> _loadEpubController() async {
    // const url = "https://www.gutenberg.org/ebooks/74515.epub3.images";
    const url2 =
        'https://github.com/daisy/epub-accessibility-tests/releases/download/fundamental-2.0/Fundamental-Accessibility-Tests-Basic-Functionality-v2.0.0.epub';

    //

    return EpubController(
      // epubCfi: 'epubcfi(/6/26[id4]!/4/2/2[id4]/22)',
      // epubCfi:
      //     'epubcfi(/6/26[id4]!/4/2/2[id4]/22)', // book.epub Chapter 3 paragraph 10
      // epubCfi:
      //     'epubcfi(/6/6[chapter-2]!/4/2/1612)', // book_2.epub Chapter 16 paragraph 3
      document: EpubDocument.openData(
        await InternetFile.get(url2),
      ),
    );
    // document: EpubDocument.openAsset(
    //     'assets/New-Findings-on-Shirdi-Sai-Baba.epub'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('EPUB Reader'),
      ),
      body: FutureBuilder<EpubController>(
        future: _loadEpubController(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Display a loading indicator while the EPUB is loading
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            // Handle any error while loading
            return Center(child: Text('Error loading EPUB: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final epubController = snapshot.data!;

            return Scaffold(
              appBar: AppBar(
                title: EpubViewActualChapter(
                  controller: epubController,
                  builder: (chapterValue) => Text(
                    chapterValue?.chapter?.Title?.replaceAll('\n', '').trim() ??
                        '',
                    textAlign: TextAlign.start,
                  ),
                ),
                actions: <Widget>[
                  IconButton(
                    icon: const Icon(Icons.save_alt),
                    color: Colors.white,
                    onPressed: () =>
                        _showCurrentEpubCfi(context, epubController),
                  ),
                ],
              ),
              drawer: Drawer(
                child: EpubViewTableOfContents(controller: epubController),
              ),
              body: EpubView(
                builders: EpubViewBuilders<DefaultBuilderOptions>(
                  options: const DefaultBuilderOptions(),
                  chapterDividerBuilder: (_) => const Divider(),
                ),
                controller: epubController,
              ),
            );
          } else {
            return const Center(child: Text('No data available'));
          }
        },
      ),
    );
  }

  void _showCurrentEpubCfi(
      BuildContext context, EpubController epubController) {
    final cfi = epubController.generateEpubCfi();

    if (cfi != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(cfi),
          action: SnackBarAction(
            label: 'GO',
            onPressed: () {
              epubController.gotoEpubCfi(cfi);
            },
          ),
        ),
      );
    }
  }
}
