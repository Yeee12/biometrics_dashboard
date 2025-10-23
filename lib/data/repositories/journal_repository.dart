import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';
import '../models/journal_entry.dart';
import '../../core/constants/app_constants.dart';

class JournalRepository {
  final Random _random = Random();
  List<JournalEntry>? _cachedData;
  Future<List<JournalEntry>> loadJournals() async {
    if (_cachedData != null) {
      return _cachedData!;
    }

    try {
      await _simulateLatency();
      _simulateFailure();
      final jsonString = await rootBundle.loadString('assets/data/journal.json');
      final List<dynamic> jsonList = json.decode(jsonString);

      _cachedData = jsonList
          .map((json) => JournalEntry.fromJson(json as Map<String, dynamic>))
          .toList()
        ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
      return _cachedData!;
    } catch (e) {
      throw DataParsingException('Failed to parse journal data: $e');
    }
  }

  Future<void> _simulateLatency() async {
    final delayMs = AppConstants.minLatencyMs +
        _random.nextInt(AppConstants.maxLatencyMs - AppConstants.minLatencyMs);
    await Future.delayed(Duration(milliseconds: delayMs));
  }

  void _simulateFailure() {
    if (_random.nextDouble() < AppConstants.failureRate) {
      throw NetworkException('Network error while fetching journal data (simulated)');
    }
  }

  void clearCache() {
    _cachedData = null;
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
