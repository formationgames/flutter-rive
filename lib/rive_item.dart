// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_rive/rive_animation.dart';
import 'package:rive/rive.dart';

final r = Random();

class RiveItem extends StatefulWidget {
  const RiveItem({
    required this.model,
    this.artboard,
    this.machine,
    this.images = const {},
    super.key,
  });

  final String model;
  final String? artboard;
  final String? machine;
  final Map<String, RenderImage?> images;

  @override
  createState() => _RiveItem();
}

class _RiveItem extends State<RiveItem> {
  // Data to inject into the view model at runtime
  final Map<String, dynamic> _data = {};

  @override
  initState() {
    super.initState();

    // Initialise view model data
    _randomiseData();

    // Periodically update the inputs
    Timer.periodic(Duration(seconds: 3), (_) {
      _randomiseData();
      if (mounted) setState(() {});
    });
  }

  // Randomise the data to inject
  void _randomiseData() {
    _data['Color'] = r.nextInt(5);
    _data['Number'] = r.nextInt(30) + 65;
    _data['Cards Count'] = r.nextInt(2) + 1;
    _data['Min Form'] = r.nextInt(2) + 2;
    _data['Max Form'] = r.nextInt(1) + 4;
  }

  @override
  build(context) {
    return RiveAnimation(
      src: 'assets/animations/card.riv',
      artboard: widget.artboard,
      machine: widget.machine,
      model: widget.model,
      data: _data,
      images: widget.images,
    );
  }
}
