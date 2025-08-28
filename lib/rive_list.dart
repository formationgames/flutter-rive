// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_rive/rive_item.dart';
import 'package:rive/rive.dart';

final r = Random();

class RiveList extends StatefulWidget {
  const RiveList({super.key});

  @override
  createState() => _RiveList();
}

class _RiveList extends State<RiveList> {
  // Cache of processed images by filepath
  final Map<String, (String key, RenderImage? image)> _images = {};

  /// Resolve image data
  Map<String, RenderImage?> _resolveImages(Map<String, String> images) {
    // Process all images in the background
    for (var entry in images.entries) {
      _processImage(entry.key, entry.value);
    }

    // Transform the cache from filename keys back to the original keys
    return _images.entries.fold(<String, RenderImage>{}, (acc, entry) {
      if (entry.value.$2 == null) return acc;
      return acc..[entry.value.$1] = entry.value.$2!;
    });
  }

  /// Process image data asynchronously in the background
  void _processImage(String key, String filepath) {
    // Skip if already processed
    if (_images.containsKey(filepath)) return;

    // Create key to mark as processing
    _images[filepath] = (key, null);

    // Trigger background processing
    unawaited(
      Future(() async {
        try {
          // Load the raw data for the image resource
          final data = await rootBundle.load(filepath);

          // Decode into rives format
          final decoded = await Factory.rive.decodeImage(
            data.buffer.asUint8List(),
          );
          if (decoded == null) {
            return print('RIVE no decoded image data: $key');
          }

          // Store processed image in the cache
          _images[filepath] = (key, decoded);

          // Rebuild the component
          if (mounted) setState(() {});
        } catch (e) {
          print('RIVE processImage: $key: $e');
        }
      }),
    );
  }

  @override
  build(context) {
    // Dynamically resolve images
    final images = _resolveImages({
      'base': 'assets/images/base.png',
      'core': 'assets/images/core.png',
      'elite': 'assets/images/elite.png',
      'rare': 'assets/images/rare.png',
      'star': 'assets/images/star.png',
      'superstar': 'assets/images/superstar.png',
    });

    // Build list of animations
    return SingleChildScrollView(
      child: Column(
        children: [
          Text('BIG'),
          RiveItem(artboard: 'Main Big', model: 'Main', images: images),
          // Text('MID'),
          // RiveItem(artboard: 'Main Mid', model: 'Main', images: images),
          // Text('SML'),
          // RiveItem(artboard: 'Main Small', model: 'Main', images: images),
        ],
      ),
    );
  }
}
