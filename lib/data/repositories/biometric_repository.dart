import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';
import '../models/biometric_data.dart';


class BiometricRepository {
  final Random _random = Random();
  List<BiometricData>? _cachedData;
  List<BiometricData>? _largeCachedData;
  Future<List<BiometricData>> loadBiometrics() async {
    if (_cachedData != null) {
      return _cachedData!;
    }

    try {
      await _simulateLatency();
      _simulateFailure();
      final jsonString = await rootBundle.loadString('assets/data/biometric_90d.json');
      final List<dynamic> jsonList = json.decode(jsonString);

      _cachedData = jsonList
          .map((json) => BiometricData.fromJson(json as Map<String, dynamic>))
          .toList()
        ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
      return _cachedData!;
    } catch (e) {
      throw DataParsingException('Failed to parse biometrics: $e');
    }
  }

  Future<List<BiometricData>> loadLargeDataset() async {
    if (_largeCachedData != null) {
      return _largeCachedData!;
    }

    try {
      final delayMs = 1200 + _random.nextInt(801);
      await Future.delayed(Duration(milliseconds: delayMs));

      _simulateFailure();

      final jsonString = await rootBundle.loadString('assets/data/biometric_90d.json');
      final List<dynamic> jsonList = json.decode(jsonString);
      final baseData = jsonList
          .map((json) => BiometricData.fromJson(json as Map<String, dynamic>))
          .toList();
      _largeCachedData = _generateLargeDataset(baseData);
      return _largeCachedData!;
    } catch (e) {
      throw DataParsingException('Failed to generate large dataset: $e');
    }
  }

  List<BiometricData> _generateLargeDataset(List<BiometricData> baseData) {
    if (baseData.isEmpty) return [];

    final result = <BiometricData>[];
    final targetPoints = 10000;
    final basePoints = baseData.length;
    final pointsPerSegment = (targetPoints / basePoints).ceil();

    for (int i = 0; i < baseData.length - 1; i++) {
      final current = baseData[i];
      final next = baseData[i + 1];

      result.add(current);

      for (int j = 1; j < pointsPerSegment; j++) {
        final ratio = j / pointsPerSegment;

        final interpolatedDate = current.dateTime.add(
          Duration(
            milliseconds:
            (next.dateTime.difference(current.dateTime).inMilliseconds * ratio).round(),
          ),
        );

        final hrvNoise = (_random.nextDouble() - 0.5) * 10;
        final rhrNoise = (_random.nextInt(5) - 2);
        final stepsNoise = (_random.nextInt(1000) - 500);

        result.add(BiometricData(
          date: interpolatedDate.toString().substring(0, 10),
          hrv: _interpolate(current.hrv, next.hrv, ratio) + hrvNoise,
          rhr: current.rhr != null && next.rhr != null
              ? (_interpolate(current.rhr!.toDouble(), next.rhr!.toDouble(), ratio) + rhrNoise)
              .round()
              : null,
          steps: current.steps != null && next.steps != null
              ? (_interpolate(current.steps!.toDouble(), next.steps!.toDouble(), ratio) + stepsNoise)
              .round()
              : null,
          sleepScore: current.sleepScore != null && next.sleepScore != null
              ? (_interpolate(
              current.sleepScore!.toDouble(), next.sleepScore!.toDouble(), ratio))
              .round()
              : null,
        ));
      }
    }

    result.add(baseData.last);
    return result..sort((a, b) => a.dateTime.compareTo(b.dateTime));
  }

  double _interpolate(double? start, double? end, double ratio) {
    if (start == null || end == null) return 0.0;
    return start + (end - start) * ratio;
  }

  Future<void> _simulateLatency() async {
    final latency = 700 + _random.nextInt(501);
    await Future.delayed(Duration(milliseconds: latency));
  }

  void _simulateFailure() {
    if (_random.nextInt(100) < 10) {
      throw NetworkException('Network error: Connection timeout (simulated)');
    }
  }

  void clearCache() {
    _cachedData = null;
    _largeCachedData = null;
  }
}

class NetworkException implements Exception {
  final String message;
  NetworkException(this.message);

  @override
  String toString() => 'NetworkException: $message';
}

class DataParsingException implements Exception {
  final String message;
  DataParsingException(this.message);

  @override
  String toString() => 'DataParsingException: $message';
}