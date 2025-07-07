import 'package:sensors_plus/sensors_plus.dart';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';

class ShakeDetector {
  final Function() onShake;
  final bool enabled;

  double _lastX = 0;
  double _lastY = 0;
  double _lastZ = 0;
  DateTime _lastShakeTime = DateTime.now();
  static const double _shakeThreshold = 12.0;
  static const int _minShakeInterval = 1000; // 1 second minimum between shakes

  ShakeDetector({
    required this.onShake,
    this.enabled = true,
  });

  void startListening() {
    accelerometerEvents.listen((AccelerometerEvent event) {
      if (!enabled) return;

      DateTime now = DateTime.now();

      // Calculate acceleration change
      double deltaX = (event.x - _lastX).abs();
      double deltaY = (event.y - _lastY).abs();
      double deltaZ = (event.z - _lastZ).abs();

      // Update last values
      _lastX = event.x;
      _lastY = event.y;
      _lastZ = event.z;

      // Calculate total acceleration change
      double accelerationChange = deltaX + deltaY + deltaZ;

      // Debug output
      if (kDebugMode) {
        print('Acceleration change: ${accelerationChange.toStringAsFixed(2)}');
      }

      // Check if enough time has passed since last shake
      if (now.difference(_lastShakeTime).inMilliseconds < _minShakeInterval) {
        return;
      }

      // Detect shake
      if (accelerationChange > _shakeThreshold) {
        if (kDebugMode) {
          print(
              'SHAKE DETECTED! Change: ${accelerationChange.toStringAsFixed(2)}');
        }

        _lastShakeTime = now;
        onShake();
      }
    });
  }

  void reset() {
    _lastX = 0;
    _lastY = 0;
    _lastZ = 0;
    _lastShakeTime = DateTime.now();
  }

  void setEnabled(bool enabled) {
    if (!enabled) {
      reset();
    }
  }
}
