// ignore_for_file: avoid_print

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

class RiveAnimation extends StatefulWidget {
  const RiveAnimation({
    required this.src,
    required this.model,
    this.artboard,
    this.machine,
    this.data = const {},
    this.images = const {},
    super.key,
  });

  final String src;
  final String model;
  final String? artboard;
  final String? machine;
  final Map<String, dynamic> data;
  final Map<String, RenderImage?> images;

  @override
  createState() => _RiveAnimation();
}

class _RiveAnimation extends State<RiveAnimation> {
  /// The rive resource loaded from disk with images injected
  File? _file;

  /// The rive animation controller
  RiveWidgetController? _controller;

  /// The view model instance to update
  ViewModelInstance? _model;

  // Has initialisation been started
  bool _init = false;

  @override
  didUpdateWidget(prev) {
    // Sync all incoming data with the rive view models
    _syncModels();

    super.didUpdateWidget(prev);
  }

  @override
  dispose() {
    _file?.dispose();
    _controller?.dispose();
    _model?.dispose();
    super.dispose();
  }

  @override
  build(context) {
    try {
      // Load the file if it hasn't been loaded yet
      if (_controller == null) {
        if (!_init) {
          _init = true;
          unawaited(_initRive());
        }

        // Wait for the file to load
        return SizedBox.shrink();
      }

      // Return the animation
      return RiveWidget(controller: _controller!, fit: Fit.contain);
    } catch (e) {
      print('-----------------------> ERROR: $e');
      rethrow;
    }
  }

  /// Load the rive file and initialise the controller
  Future<void> _initRive() async {
    try {
      // Load the rive file
      _file ??= await File.asset(widget.src, riveFactory: Factory.rive);

      // Initialise the controller with the file
      final artboard = widget.artboard;
      final machine = widget.machine;
      _controller ??= RiveWidgetController(
        _file!,
        artboardSelector: artboard == null || artboard.isEmpty
            ? const ArtboardDefault()
            : ArtboardSelector.byName(artboard),
        stateMachineSelector: machine == null || machine.isEmpty
            ? const StateMachineDefault()
            : StateMachineSelector.byName(machine),
      );

      // Create view model instance
      final vm = _file?.viewModelByName(widget.model);
      _model ??= vm?.createDefaultInstance();

      // Sync data and images
      _syncModels();

      // Rebuild the component
      if (mounted) setState(() {});
    } catch (e) {
      print('-----------------------> INIT: $e');
      rethrow;
    }
  }

  /// Sync all incoming data with the rive view models
  void _syncModels() {
    // Sync all data properties with view models
    for (var entry in widget.data.entries) {
      final type = entry.value.runtimeType;
      switch (entry.value) {
        case String x:
          final prop = _model?.string(entry.key);
          if (prop == null) {
            print('RIVE no $type property: ${entry.key}');
            continue;
          }
          prop.value = x;
        case double x:
          final prop = _model?.number(entry.key);
          if (prop == null) {
            print('RIVE no $type property: ${entry.key}');
            continue;
          }
          prop.value = x;
        case int x:
          final prop = _model?.number(entry.key);
          if (prop == null) {
            print('RIVE no $type property: ${entry.key}');
            continue;
          }
          prop.value = x.toDouble();
        case bool x:
          final prop = _model?.boolean(entry.key);
          if (prop == null) {
            print('RIVE no $type property: ${entry.key}');
            continue;
          }
          prop.value = x;
        default:
          print('RIVE no support for property type: $type ${entry.key}');
      }
    }

    // Sync all image properties with view models
    for (var entry in widget.images.entries) {
      final prop = _model?.image(entry.key);
      if (prop == null) {
        print('RIVE no image prop: $prop');
        continue;
      }
      prop.value = entry.value;
    }

    // Bind the view model instance to the state machine
    _controller?.dataBind(DataBind.byInstance(_model!));
  }
}
