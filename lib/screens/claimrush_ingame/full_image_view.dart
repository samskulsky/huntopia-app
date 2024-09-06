import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class FullImageView extends StatefulWidget {
  const FullImageView({super.key});

  @override
  State<FullImageView> createState() => _FullImageViewState();
}

String imUrl = '';

class _FullImageViewState extends State<FullImageView> {
  Future<void> _shareImage() async {
    try {
      final Uint8List bytes = await _downloadImage(imUrl);
      final String filePath = await _saveImageToTempFile(bytes);
      await _shareFile(filePath);
      await _deleteTempFile(filePath);
    } catch (e) {
      _showErrorSnackBar('Failed to share the image');
    }
  }

  Future<Uint8List> _downloadImage(String url) async {
    final http.Response response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return response.bodyBytes;
    } else {
      throw Exception('Failed to download image');
    }
  }

  Future<String> _saveImageToTempFile(Uint8List bytes) async {
    final Directory tempDir = await getTemporaryDirectory();
    final File file = File('${tempDir.path}/image.png');
    await file.writeAsBytes(bytes);
    return file.path;
  }

  Future<void> _shareFile(String filePath) async {
    final XFile xFile = XFile(filePath);
    await Share.shareXFiles([xFile]);
  }

  Future<void> _deleteTempFile(String filePath) async {
    final File file = File(filePath);
    if (await file.exists()) {
      await file.delete();
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const FaIcon(FontAwesomeIcons.arrowLeft),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Image'),
        actions: [
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.share),
            onPressed: _shareImage,
          ),
        ],
      ),
      body: Center(
        child: Image.network(imUrl),
      ),
    );
  }
}
