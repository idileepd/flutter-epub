import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:epub_plus/epub_plus.dart';
import 'package:html/parser.dart' as htmlparser;
import 'package:html/dom.dart' as dom;
import 'package:csslib/parser.dart' as cssparser;
import 'package:csslib/visitor.dart' as csslib;
import 'package:flutter/src/widgets/image.dart' as img;
import 'package:path/path.dart' as path;

class EpubContentWidget extends StatefulWidget {
  final EpubBook epubBook;

  const EpubContentWidget({super.key, required this.epubBook});

  @override
  _EpubContentWidgetState createState() => _EpubContentWidgetState();
}

class _EpubContentWidgetState extends State<EpubContentWidget> {
  int _currentChapterIndex = 0;
  late Map<String, Map<String, dynamic>> _styles;

  @override
  void initState() {
    super.initState();
    _styles = _parseStyles();
  }

  Map<String, Map<String, dynamic>> _parseStyles() {
    Map<String, Map<String, dynamic>> styles = {};
    widget.epubBook.content?.css?.forEach((_, cssFile) {
      var stylesheet = cssparser.parse(cssFile.content!);
      stylesheet.topLevels.forEach((rule) {
        if (rule is csslib.RuleSet) {
          rule.selectorGroup?.selectors.forEach((selector) {
            var selectorText = selector.toString();
            styles[selectorText] = {};
            // rule.declarationGroup.declarations.forEach((declaration) {
            //   styles[selectorText]![declaration] = declaration;
            // });
          });
        }
      });
    });
    return styles;
  }

  @override
  Widget build(BuildContext context) {
    print(widget.epubBook.authors);
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
      return const Center(child: Text('No chapters available'));
    }

    EpubChapter currentChapter = widget.epubBook.chapters[_currentChapterIndex];
    String chapterContent = currentChapter.htmlContent ?? '';

    try {
      print(chapterContent);
      var document = htmlparser.parse(chapterContent);
      print(document);
      return SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _buildWidgets(document.body!),
          ),
        ),
      );
    } catch (e) {
      return Center(child: Text('Error parsing chapter content: $e'));
    }
  }

  List<Widget> _buildWidgets(dom.Element element) {
    List<Widget> widgets = [];
    print(element.nodes);
    for (var node in element.nodes) {
      if (node is dom.Element) {
        switch (node.localName) {
          case 'p':
            widgets.add(Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: RichText(
                text: TextSpan(
                  style: _getStyleForElement(node),
                  children: _parseTextNodes(node),
                ),
              ),
            ));
            break;
          case 'h1':
          case 'h2':
          case 'h3':
          case 'h4':
          case 'h5':
          case 'h6':
            widgets.add(Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Text(
                node.text,
                style: _getStyleForElement(node).copyWith(
                  fontSize: 24 - (int.parse(node.localName![1]) * 2),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ));
            break;
          case 'img':
            widgets.add(_handleInlineImage(node.attributes));
            break;
          case 'ul':
          case 'ol':
            widgets.add(_buildList(node));
            break;
          case 'table':
            widgets.add(_buildTable(node));
            break;
          default:
            widgets.addAll(_buildWidgets(node));
        }
      } else if (node is dom.Text) {
        String text = node.text.trim();
        if (text.isNotEmpty) {
          widgets.add(Text(text, style: _getStyleForElement(element)));
        }
      }
    }
    return widgets;
  }

  List<TextSpan> _parseTextNodes(dom.Element element) {
    List<TextSpan> textSpans = [];
    for (var node in element.nodes) {
      if (node is dom.Text) {
        textSpans.add(TextSpan(text: node.text));
      } else if (node is dom.Element) {
        TextStyle style = _getStyleForElement(node);
        switch (node.localName) {
          case 'strong':
          case 'b':
            style = style.copyWith(fontWeight: FontWeight.bold);
            break;
          case 'em':
          case 'i':
            style = style.copyWith(fontStyle: FontStyle.italic);
            break;
          case 'u':
            style = style.copyWith(decoration: TextDecoration.underline);
            break;
        }
        textSpans.add(TextSpan(
          style: style,
          children: _parseTextNodes(node),
        ));
      }
    }
    return textSpans;
  }

  TextStyle _getStyleForElement(dom.Element element) {
    var style = const TextStyle(fontSize: 16, color: Colors.black);
    _styles.forEach((selector, properties) {
      if (_elementMatchesSelector(element, selector)) {
        properties.forEach((property, value) {
          switch (property) {
            case 'font-size':
              style = style.copyWith(
                  fontSize: double.tryParse(
                      value.replaceAll(RegExp(r'[^0-9.]'), '')));
              break;
            case 'color':
              style = style.copyWith(color: _parseColor(value));
              break;
            case 'font-weight':
              style = style.copyWith(
                  fontWeight:
                      value == 'bold' ? FontWeight.bold : FontWeight.normal);
              break;
            case 'font-style':
              style = style.copyWith(
                  fontStyle:
                      value == 'italic' ? FontStyle.italic : FontStyle.normal);
              break;
            case 'text-decoration':
              style = style.copyWith(
                  decoration: value.contains('underline')
                      ? TextDecoration.underline
                      : TextDecoration.none);
              break;
          }
        });
      }
    });
    return style;
  }

  bool _elementMatchesSelector(dom.Element element, String selector) {
    if (selector.startsWith('.')) {
      return element.classes.contains(selector.substring(1));
    } else if (selector.startsWith('#')) {
      return element.id == selector.substring(1);
    } else {
      return element.localName == selector;
    }
  }

  Color _parseColor(String color) {
    if (color.startsWith('#')) {
      return Color(int.parse(color.substring(1, 7), radix: 16) + 0xFF000000);
    }
    // Add more color parsing logic as needed
    return Colors.black;
  }

  // Widget _handleInlineImage(Map<Object, String> attributes) {
  //   print(attributes['src']);
  //   String? src = attributes['src'];
  //   if (src == null) return SizedBox.shrink();
  //   print(widget.epubBook.content?.images);

  //   EpubByteContentFile? imageFile = widget.epubBook.content?.images?[src];
  //   if (imageFile == null) return SizedBox.shrink();

  //   return img.Image.memory(
  //     Uint8List.fromList(imageFile.content!),
  //     fit: BoxFit.contain,
  //   );
  // }
  Widget _handleInlineImage(Map<Object, String> attributes) {
    print("Images---");
    print(attributes);
    String? src = attributes['src'];
    if (src == null) return const SizedBox.shrink();

    // Normalize the path
    String normalizedSrc = path.normalize(src);

    // Remove any parent directory references
    normalizedSrc = normalizedSrc.replaceAll(RegExp(r'^(\.\.\/)*'), '');

    // Find the image in the EPUB content
    EpubByteContentFile? imageFile =
        widget.epubBook.content?.images?[normalizedSrc];

    // if (imageFile == null) {
    //   // If not found, try to find by the filename only
    //   String fileName = path.basename(normalizedSrc);
    //   imageFile = widget.epubBook.content?.images?.values
    //       .firstWhere((file) => path.basename(file.fileName!) == fileName,
    //           orElse: () => null);
    // }

    if (imageFile == null) {
      print('Image not found: $src');
      return const SizedBox.shrink();
    }

    return img.Image.memory(
      Uint8List.fromList(imageFile.content!),
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        print('Error loading image: $error');
        return const Icon(Icons.broken_image);
      },
    );
  }

  Widget _buildList(dom.Element listElement) {
    bool isOrdered = listElement.localName == 'ol';
    List<Widget> listItems = [];
    int index = 1;

    for (var item in listElement.children) {
      if (item.localName == 'li') {
        listItems.add(
          Padding(
            padding: const EdgeInsets.only(left: 16.0, top: 4.0, bottom: 4.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isOrdered ? '${index++}. ' : '• ',
                  style: _getStyleForElement(item),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _buildWidgets(item),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    }

    return Column(children: listItems);
  }

  Widget _buildTable(dom.Element tableElement) {
    List<TableRow> rows = [];

    for (var row in tableElement.children) {
      if (row.localName == 'tr') {
        List<Widget> cells = [];
        for (var cell in row.children) {
          if (cell.localName == 'td' || cell.localName == 'th') {
            cells.add(
              TableCell(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _buildWidgets(cell),
                  ),
                ),
              ),
            );
          }
        }
        rows.add(TableRow(children: cells));
      }
    }

    return Table(
      border: TableBorder.all(color: Colors.grey),
      children: rows,
    );
  }

  Widget _buildNavigationBar() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _currentChapterIndex > 0 ? _previousChapter : null,
          ),
          Text(
              'Chapter ${_currentChapterIndex + 1} of ${widget.epubBook.chapters.length}'),
          IconButton(
            icon: const Icon(Icons.arrow_forward),
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
