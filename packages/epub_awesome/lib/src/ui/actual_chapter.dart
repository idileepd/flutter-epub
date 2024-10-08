import 'package:epub_awesome/src/data/models/chapter_view_value.dart';
import 'package:epub_awesome/src/ui/epub_awesome.dart';
import 'package:flutter/material.dart';

typedef ChapterBuilder = Widget Function(EpubChapterViewValue? chapter);

class EpubViewActualChapter extends StatelessWidget {
  const EpubViewActualChapter({
    required this.controller,
    required this.builder,
    this.loader,
    this.animationAlignment = Alignment.centerLeft,
    super.key,
  });

  final EpubController controller;
  final ChapterBuilder builder;
  final Widget? loader;
  final Alignment animationAlignment;

  @override
  Widget build(BuildContext context) =>
      ValueListenableBuilder<EpubChapterViewValue?>(
        valueListenable: controller.currentValueListenable,
        builder: (_, data, child) {
          Widget content;

          if (data != null) {
            content = KeyedSubtree(
              key: Key('$runtimeType.chapter-${data.chapterNumber}'),
              child: builder(data),
            );
          } else {
            content = KeyedSubtree(
              key: Key('$runtimeType.loader'),
              child: loader ?? const Center(child: CircularProgressIndicator()),
            );
          }

          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            switchInCurve: Curves.easeIn,
            switchOutCurve: Curves.easeOut,
            transitionBuilder: (Widget child, Animation<double> animation) =>
                SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, -0.15),
                end: const Offset(0, 0),
              ).animate(animation),
              child: FadeTransition(opacity: animation, child: child),
            ),
            layoutBuilder:
                (Widget? currentChild, List<Widget> previousChildren) => Stack(
              alignment: animationAlignment,
              children: <Widget>[
                ...previousChildren,
                if (currentChild != null) currentChild,
              ],
            ),
            child: content,
          );
        },
      );
}
