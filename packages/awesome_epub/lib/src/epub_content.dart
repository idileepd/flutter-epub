import 'package:flutter/material.dart';
import 'package:epubx/epubx.dart';
import 'package:flutter_html/flutter_html.dart';

class EpubContentWidget extends StatelessWidget {
  final EpubBook epubBook;

  const EpubContentWidget({super.key, required this.epubBook});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Display the book title
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Title: ${epubBook.Title}',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),

        // Display the list of chapters and their content
        Expanded(
          child: ListView.builder(
            itemCount: epubBook.Chapters?.length ?? 0,
            itemBuilder: (context, index) {
              final chapter = epubBook.Chapters![index];

              return ExpansionTile(
                title: Text(
                  chapter.Title ?? 'No Chapter Title',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w500),
                ),
                children: [
                  // Render HTML content of each chapter using flutter_html
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Html(
                      data:
                          chapter.HtmlContent ?? '<p>No Content Available</p>',
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
