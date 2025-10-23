import 'dart:math';
import '../models/biometric_data.dart';
import '../../core/constants/app_constants.dart';

class DataDecimator {
  static List<BiometricData> decimate({
    required List<BiometricData> data,
    required int threshold,
    required double? Function(BiometricData) getValue,
  }) {
    if (threshold <= 0) {
      throw ArgumentError('Threshold must be positive');
    }

    if (threshold >= data.length || data.length <= 2) {
      return List.from(data);
    }
    final sampled = <BiometricData>[data.first];

    final bucketSize = (data.length - 2) / (threshold - 2);

    int a = 0;

    for (int i = 0; i < threshold - 2; i++) {
      final avgRangeStart = ((i + 1) * bucketSize).floor() + 1;
      final avgRangeEnd = ((i + 2) * bucketSize).floor() + 1;
      final avgRangeEndClamped = min(avgRangeEnd, data.length);

      double avgX = 0;
      double avgY = 0;
      int avgCount = 0;

      for (int j = avgRangeStart; j < avgRangeEndClamped; j++) {
        final value = getValue(data[j]);
        if (value != null) {
          avgX += j.toDouble();
          avgY += value;
          avgCount++;
        }
      }

      if (avgCount > 0) {
        avgX /= avgCount;
        avgY /= avgCount;
      }
      final rangeStart = ((i + 0) * bucketSize).floor() + 1;
      final rangeEnd = ((i + 1) * bucketSize).floor() + 1;

      double maxArea = -1;
      int maxAreaIndex = rangeStart;

      final pointAX = a.toDouble();
      final pointAY = getValue(data[a]) ?? 0;

      for (int j = rangeStart; j < rangeEnd; j++) {
        final pointBY = getValue(data[j]);
        if (pointBY == null) continue;
        final area = ((pointAX - avgX) * (pointBY - pointAY) -
            (pointAX - j) * (avgY - pointAY))
            .abs();

        if (area > maxArea) {
          maxArea = area;
          maxAreaIndex = j;
        }
      }

      sampled.add(data[maxAreaIndex]);
      a = maxAreaIndex;
    }

    sampled.add(data.last);

    return sampled;
  }

  static List<BiometricData> decimateHRV(
      List<BiometricData> data,
      int threshold,
      ) {
    return decimate(
      data: data,
      threshold: threshold,
      getValue: (d) => d.hrv,
    );
  }

  static List<BiometricData> decimateRHR(
      List<BiometricData> data,
      int threshold,
      ) {
    return decimate(
      data: data,
      threshold: threshold,
      getValue: (d) => d.rhr?.toDouble(),
    );
  }

  static List<BiometricData> decimateSteps(
      List<BiometricData> data,
      int threshold,
      ) {
    return decimate(
      data: data,
      threshold: threshold,
      getValue: (d) => d.steps?.toDouble(),
    );
  }

  static bool shouldDecimate(int dataLength) {
    return dataLength > AppConstants.decimationThreshold;
  }
}