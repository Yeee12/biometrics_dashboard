import '../models/biometric_data.dart';
import '../models/journal_entry.dart';

class DataValidator {
  static List<BiometricData> validateBiometricData(List<BiometricData> data) {
    final validData = <BiometricData>[];
    int skippedCount = 0;
    int imputedCount = 0;

    for (int i = 0; i < data.length; i++) {
      final record = data[i];
      if (!_isValidDate(record.date)) {
        skippedCount++;
        continue;
      }

      if (!_hasAnyValidMetric(record)) {
        skippedCount++;
        continue;
      }

      final cleaned = _imputeMissingValues(record, data, i);
      if (cleaned != record) {
        imputedCount++;
      }

      validData.add(cleaned);
    }
    return validData;
  }


  static List<JournalEntry> validateJournalEntries(List<JournalEntry> journals) {
    final validJournals = journals.where((journal) {
      if (!_isValidDate(journal.date)) {
        return false;
      }

      if (journal.mood < 1 || journal.mood > 5) {
        return false;
      }

      if (journal.note.trim().isEmpty) {
      }

      return true;
    }).toList();
    return validJournals;
  }

  static bool _isValidDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();

      if (date.isAfter(now)) {
        return false;
      }
      if (date.year < 2000) {
        return false;
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  static bool _hasAnyValidMetric(BiometricData record) {
    return _isValidHRV(record.hrv) ||
        _isValidRHR(record.rhr) ||
        _isValidSteps(record.steps);
  }

  static bool _isValidHRV(double? hrv) {
    if (hrv == null) return false;
    return hrv >= 10 && hrv <= 200;
  }

  static bool _isValidRHR(int? rhr) {
    if (rhr == null) return false;
    return rhr >= 30 && rhr <= 120;
  }

  static bool _isValidSteps(int? steps) {
    if (steps == null) return false;
    return steps >= 0 && steps <= 100000;
  }

  static BiometricData _imputeMissingValues(
      BiometricData record,
      List<BiometricData> allData,
      int currentIndex,
      ) {
    BiometricData result = record;

    if (!_isValidHRV(record.hrv)) {
      final imputedHRV = _interpolateMetric(
        allData,
        currentIndex,
            (data) => data.hrv,
        _isValidHRV,
      );
      if (imputedHRV != null) {
        result = BiometricData(
          date: result.date,
          hrv: imputedHRV,
          rhr: result.rhr,
          steps: result.steps,
          sleepScore: result.sleepScore,
        );
      }
    }

    if (!_isValidRHR(record.rhr)) {
      final imputedRHR = _interpolateMetric(
        allData,
        currentIndex,
            (data) => data.rhr?.toDouble(),
            (val) => _isValidRHR(val?.toInt()),
      );
      if (imputedRHR != null) {
        result = BiometricData(
          date: result.date,
          hrv: result.hrv,
          rhr: imputedRHR.round(),
          steps: result.steps,
          sleepScore: result.sleepScore,
        );
      }
    }

    if (!_isValidSteps(record.steps)) {
      final imputedSteps = _interpolateMetric(
        allData,
        currentIndex,
            (data) => data.steps?.toDouble(),
            (val) => _isValidSteps(val?.toInt()),
      );
      if (imputedSteps != null) {
        result = BiometricData(
          date: result.date,
          hrv: result.hrv,
          rhr: result.rhr,
          steps: imputedSteps.round(),
          sleepScore: result.sleepScore,
        );
      }
    }

    return result;
  }


  static double? _interpolateMetric(
      List<BiometricData> data,
      int currentIndex,
      double? Function(BiometricData) getValue,
      bool Function(double?) isValid,
      ) {
    double? prevValue;
    int prevIndex = currentIndex - 1;
    while (prevIndex >= 0 && prevValue == null) {
      final val = getValue(data[prevIndex]);
      if (isValid(val)) {
        prevValue = val;
        break;
      }
      prevIndex--;
    }

    double? nextValue;
    int nextIndex = currentIndex + 1;
    while (nextIndex < data.length && nextValue == null) {
      final val = getValue(data[nextIndex]);
      if (isValid(val)) {
        nextValue = val;
        break;
      }
      nextIndex++;
    }

    if (prevValue != null && nextValue != null) {
      final totalDistance = (nextIndex - prevIndex).toDouble();
      final currentDistance = (currentIndex - prevIndex).toDouble();
      final ratio = currentDistance / totalDistance;
      return prevValue + (nextValue - prevValue) * ratio;
    }

    if (prevValue != null) return prevValue;

    if (nextValue != null) return nextValue;

    return null;
  }
}