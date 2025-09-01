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
    _data['Color'] = r.nextInt(6);
    _data['Number'] = r.nextInt(30) + 65;
    _data['Cards Count'] = r.nextInt(3) + 1;
    _data['Min Form'] = r.nextInt(3) + 2;
    _data['Max Form'] = r.nextInt(2) + 4;
  }

  @override
  build(context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 200,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Artboard: ${widget.artboard}'),
              Text('Machine: ${widget.machine}'),
              Text('Model: ${widget.model}'),
              Text('Color: ${_data['Color']}'),
              Text('Number: ${_data['Number']}'),
              Text('Cards Count: ${_data['Cards Count']}'),
              Text('Min Form: ${_data['Min Form']}'),
              Text('Max Form: ${_data['Max Form']}'),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.all(10),
          child: SizedBox(
            height: 200,
            width: 120,
            child: RepaintBoundary(
              child: RiveAnimation(
                src: 'assets/animations/card.riv',
                artboard: widget.artboard,
                machine: widget.machine,
                model: widget.model,
                data: _data,
                images: widget.images,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
