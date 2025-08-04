import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ImageLoader extends ChangeNotifier {
  final Map<String, ui.Image> _avatars = {};

  ui.Image? imageForUrl(String url) => _avatars[url];

  Future<void> downloadImage(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode != 200) return;

      ui.decodeImageFromList(Uint8List.view(response.bodyBytes.buffer), (ui.Image img) {
        _avatars[url] = img;
        notifyListeners();
      });
    } catch (e) {
      return;
    }
  }
}
