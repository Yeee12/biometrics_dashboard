import 'package:flutter_test/flutter_test.dart';
import 'package:biometrics_dashboard/data/models/biometric_data.dart';
import 'package:biometrics_dashboard/data/services/data_decimator.dart';

void main() {
  group('DataDecimator', () {
    late List<BiometricData> testData;

    setUp(() {
      testData = List.generate(
        1000,
            (i) => BiometricData(
          date: DateTime(2025, 1, 1).add(Duration(days: i)).toIso8601String().split('T')[0],
          hrv: 50.0 + (i % 20).toDouble(), // Values: 50-69
          rhr: 60 + (i % 10), // Values: 60-69
          steps: 5000 + (i * 10), // Increasing trend
        ),
      );
    });

    test('decimates to approximately target threshold', () {
      const threshold = 100;
      final decimated = DataDecimator.decimateHRV(testData, threshold);

      expect(decimated.length, greaterThanOrEqualTo(threshold - 5));
      expect(decimated.length, lessThanOrEqualTo(threshold + 5));
    });

    test('preserves first and last points', () {
      const threshold = 50;
      final decimated = DataDecimator.decimateHRV(testData, threshold);

      expect(decimated.first.date, equals(testData.first.date));
      expect(decimated.first.hrv, equals(testData.first.hrv));

      expect(decimated.last.date, equals(testData.last.date));
      expect(decimated.last.hrv, equals(testData.last.hrv));
    });

    test('preserves minimum value', () {
      const threshold = 100;
      final decimated = DataDecimator.decimateHRV(testData, threshold);

      final originalMin = testData
          .map((d) => d.hrv!)
          .reduce((a, b) => a < b ? a : b);

      final decimatedMin = decimated
          .map((d) => d.hrv!)
          .reduce((a, b) => a < b ? a : b);

      expect(decimatedMin, equals(originalMin));
    });

    test('preserves maximum value', () {
      const threshold = 100;
      final decimated = DataDecimator.decimateHRV(testData, threshold);

      final originalMax = testData
          .map((d) => d.hrv!)
          .reduce((a, b) => a > b ? a : b);

      final decimatedMax = decimated
          .map((d) => d.hrv!)
          .reduce((a, b) => a > b ? a : b);

      expect(decimatedMax, equals(originalMax));
    });

    test('handles small datasets without decimation', () {
      final smallData = testData.sublist(0, 10);
      const threshold = 50;

      final decimated = DataDecimator.decimateHRV(smallData, threshold);

      expect(decimated.length, equals(smallData.length));
    });

    test('throws error for invalid threshold', () {
      expect(
            () => DataDecimator.decimateHRV(testData, 0),
        throwsArgumentError,
      );

      expect(
            () => DataDecimator.decimateHRV(testData, -5),
        throwsArgumentError,
      );
    });

    test('handles null values gracefully', () {
      final dataWithNulls = List.generate(
        100,
            (i) => BiometricData(
          date: DateTime(2025, 1, 1).add(Duration(days: i)).toIso8601String().split('T')[0],
          hrv: i % 5 == 0 ? null : 60.0,
          rhr: 60,
          steps: 8000,
        ),
      );

      const threshold = 50;
      final decimated = DataDecimator.decimateHRV(dataWithNulls, threshold);

      // Should complete without error
      expect(decimated.length, greaterThan(0));
      expect(decimated.length, lessThanOrEqualTo(threshold + 5));
    });

    test('decimation performance benchmark', () {

      final largeData = List.generate(
        10000,
            (i) => BiometricData(
          date: DateTime(2025, 1, 1).add(Duration(days: i)).toIso8601String().split('T')[0],
          hrv: 50.0 + (i % 50).toDouble(),
          rhr: 60,
          steps: 8000,
        ),
      );

      const threshold = 500;
      final stopwatch = Stopwatch()..start();

      final decimated = DataDecimator.decimateHRV(largeData, threshold);

      stopwatch.stop();


      expect(stopwatch.elapsedMilliseconds, lessThan(100));


      expect(decimated.length, greaterThanOrEqualTo(threshold - 10));
      expect(decimated.length, lessThanOrEqualTo(threshold + 10));
    });
  });
}