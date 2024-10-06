import 'package:flutter/services.dart' show ByteData, rootBundle;
import 'package:http/http.dart' as http;
import 'package:epubx/epubx.dart';
import 'dart:io';

abstract class EPubLoader {
  Future<EpubBook> getFromAsset(String assetPath);
  Future<EpubBook> getFromApi(String url);
  Future<EpubBook> getFromPath(String filePath);
}

class DefaultEPubLoader implements EPubLoader {
  @override
  Future<EpubBook> getFromAsset(String assetPath) async {
    ByteData data = await rootBundle.load(assetPath);
    return await EpubReader.readBook(data.buffer.asUint8List());
  }

  @override
  Future<EpubBook> getFromApi(String url) async {
    var response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return await EpubReader.readBook(response.bodyBytes);
    } else {
      throw Exception('Failed to load EPUB from API');
    }
  }

  @override
  Future<EpubBook> getFromPath(String filePath) async {
    var fileBytes = await File(filePath).readAsBytes();
    return await EpubReader.readBook(fileBytes);
  }
}
