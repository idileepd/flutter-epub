import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:epub_plus/epub_plus.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter/src/widgets/image.dart' as img;

class EpubContentWidget extends StatefulWidget {
  final EpubBook epubBook;

  const EpubContentWidget({Key? key, required this.epubBook}) : super(key: key);

  @override
  _EpubContentWidgetState createState() => _EpubContentWidgetState();
}

class _EpubContentWidgetState extends State<EpubContentWidget> {
  int _currentChapterIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.epubBook.title ?? 'eBook Reader'),
      ),
      body: Column(
        children: [
          Expanded(
            child: _buildChapterContent(),
          ),
          _buildNavigationBar(),
        ],
      ),
    );
  }

  Widget _buildChapterContent() {
    if (widget.epubBook.chapters.isEmpty) {
      return Center(child: Text('No chapters available'));
    }

    EpubChapter currentChapter = widget.epubBook.chapters[_currentChapterIndex];
    String chapterContent = currentChapter.htmlContent ?? '';

    print(chapterContent);

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Html(
          data: chapterContent,
          style: {
            "body": Style(
                fontSize: FontSize(18),
                fontStyle: FontStyle.italic,
                backgroundColor: Colors.black,
                color: Colors.amberAccent),
          },

          // customRender: {
          //   "img": (context, child) {
          //     final attributes = context.tree.element?.attributes ?? {};
          //     return _handleInlineImage(attributes);
          //   },
          // },
        ),
      ),
    );
  }

  Widget _handleInlineImage(Map<String, String> attributes) {
    String? src = attributes['src'];
    if (src == null) return SizedBox.shrink();

    EpubByteContentFile? imageFile = widget.epubBook.content?.images?[src];
    if (imageFile == null) return SizedBox.shrink();

    return img.Image.memory(
      Uint8List.fromList(imageFile.content!),
      fit: BoxFit.contain,
    );
  }

  Widget _buildNavigationBar() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: _currentChapterIndex > 0 ? _previousChapter : null,
          ),
          Text(
              'Chapter ${_currentChapterIndex + 1} of ${widget.epubBook.chapters.length}'),
          IconButton(
            icon: Icon(Icons.arrow_forward),
            onPressed:
                _currentChapterIndex < widget.epubBook.chapters.length - 1
                    ? _nextChapter
                    : null,
          ),
        ],
      ),
    );
  }

  void _previousChapter() {
    if (_currentChapterIndex > 0) {
      setState(() {
        _currentChapterIndex--;
      });
    }
  }

  void _nextChapter() {
    if (_currentChapterIndex < widget.epubBook.chapters.length - 1) {
      setState(() {
        _currentChapterIndex++;
      });
    }
  }
}
