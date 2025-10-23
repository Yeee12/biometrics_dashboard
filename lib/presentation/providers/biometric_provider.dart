import 'package:biometrics_dashboard/core/constants/app_constants.dart';
import 'package:biometrics_dashboard/data/services/data_validator.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/biometric_data.dart';
import '../../data/models/journal_entry.dart';
import '../../data/repositories/biometric_repository.dart';
import '../../data/repositories/journal_repository.dart';
import '../../data/services/data_decimator.dart';
import '../../domain/entities/time_range.dart';

final biometricRepositoryProvider = Provider<BiometricRepository>((ref) {
  return BiometricRepository();
});

final journalRepositoryProvider = Provider<JournalRepository>((ref) {
  return JournalRepository();
});
class BiometricState {
  final List<BiometricData> rawData;
  final List<BiometricData> filteredData;
  final List<JournalEntry> journals;
  final TimeRange selectedRange;
  final String? hoveredDate;
  final bool isLoading;
  final String? error;
  final bool useLargeDataset;
  final bool isRetrying; // NEW

  const BiometricState({
    this.rawData = const [],
    this.filteredData = const [],
    this.journals = const [],
    this.selectedRange = TimeRange.days30,
    this.hoveredDate,
    this.isLoading = false,
    this.error,
    this.isRetrying = false, // NEW
    this.useLargeDataset = false,
  });

  BiometricState copyWith({
    List<BiometricData>? rawData,
    List<BiometricData>? filteredData,
    List<JournalEntry>? journals,
    TimeRange? selectedRange,
    String? hoveredDate,
    bool? isLoading,
    String? error,
    bool? useLargeDataset,
    bool clearHover = false,
    bool? isRetrying, // NEW
    bool clearError = false,
  }) {
    return BiometricState(
      rawData: rawData ?? this.rawData,
      filteredData: filteredData ?? this.filteredData,
      journals: journals ?? this.journals,
      selectedRange: selectedRange ?? this.selectedRange,
      hoveredDate: clearHover ? null : (hoveredDate ?? this.hoveredDate),
      isLoading: isLoading ?? this.isLoading,
      isRetrying: isRetrying ?? this.isRetrying, // NEW
      error: clearError ? null : (error ?? this.error),
      useLargeDataset: useLargeDataset ?? this.useLargeDataset,
    );
  }
}

class BiometricNotifier extends StateNotifier<BiometricState> {
  final BiometricRepository _biometricRepository;
  final JournalRepository _journalRepository;

  BiometricNotifier(
      this._biometricRepository,
      this._journalRepository,
      ) : super(const BiometricState()) {
    loadData();
  }

  Future<void> loadData() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final results = await Future.wait([
        state.useLargeDataset
            ? _biometricRepository.loadLargeDataset()
            : _biometricRepository.loadBiometrics(),
        _journalRepository.loadJournals(),
      ]);

      final rawData = results[0] as List<BiometricData>;
      final rawJournals = results[1] as List<JournalEntry>;

      final validatedData = DataValidator.validateBiometricData(rawData);
      final validatedJournals = DataValidator.validateJournalEntries(rawJournals);

      if (validatedData.isEmpty) {
        throw Exception('No valid biometric data available after validation');
      }

      final filtered = _filterByRange(validatedData, state.selectedRange);

      state = state.copyWith(
        rawData: validatedData,
        filteredData: filtered,
        journals: validatedJournals,
        isLoading: false,
      );
      final dataLoss = ((rawData.length - validatedData.length) / rawData.length * 100);
      if (dataLoss > 10) {
      }

    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void switchRange(TimeRange range) {
    final filtered = _filterByRange(state.rawData, range);
    state = state.copyWith(
      selectedRange: range,
      filteredData: filtered,
      clearHover: true,
    );
  }


  void setHoveredDate(String? date) {
    if (date == null) {
      state = state.copyWith(clearHover: true);
    } else {
      state = state.copyWith(hoveredDate: date);
    }
  }

  Future<void> toggleLargeDataset() async {
    state = state.copyWith(useLargeDataset: !state.useLargeDataset);
    await loadData();
  }

  Future<void> retry() async {
    state = state.copyWith(isRetrying: true, clearError: true);

    _biometricRepository.clearCache();
    _journalRepository.clearCache();

    await loadData();

    state = state.copyWith(isRetrying: false);
  }
  List<BiometricData> _filterByRange(
      List<BiometricData> data,
      TimeRange range,
      ) {
    if (data.isEmpty) return [];

    final latestDate = data.last.dateTime;
    final cutoffDate = latestDate.subtract(Duration(days: range.days));

    return data.where((d) => d.dateTime.isAfter(cutoffDate)).toList();
  }


  List<BiometricData> getDecimatedHRV() {
    if (!DataDecimator.shouldDecimate(state.filteredData.length)) {
      return state.filteredData;
    }
    return DataDecimator.decimateHRV(
      state.filteredData,
      AppConstants.decimationThreshold,
    );
  }

  List<BiometricData> getDecimatedRHR() {
    if (!DataDecimator.shouldDecimate(state.filteredData.length)) {
      return state.filteredData;
    }
    return DataDecimator.decimateRHR(
      state.filteredData,
      AppConstants.decimationThreshold,
    );
  }

  List<BiometricData> getDecimatedSteps() {
    if (!DataDecimator.shouldDecimate(state.filteredData.length)) {
      return state.filteredData;
    }
    return DataDecimator.decimateSteps(
      state.filteredData,
      AppConstants.decimationThreshold,
    );
  }


  List<JournalEntry> getFilteredJournals() {
    if (state.filteredData.isEmpty || state.journals.isEmpty) {
      return [];
    }

    final firstDate = state.filteredData.first.dateTime;
    final lastDate = state.filteredData.last.dateTime;
    for (var j in state.journals) {
    }

    final filtered = state.journals.where((journal) {
      final journalDate = journal.dateTime;
      final isInRange = journalDate.isAfter(firstDate.subtract(Duration(days: 1))) &&
          journalDate.isBefore(lastDate.add(Duration(days: 1)));
      return isInRange;
    }).toList();
    return filtered;
  }
}


final biometricProvider =
StateNotifierProvider<BiometricNotifier, BiometricState>((ref) {
  final biometricRepo = ref.watch(biometricRepositoryProvider);
  final journalRepo = ref.watch(journalRepositoryProvider);
  return BiometricNotifier(biometricRepo, journalRepo);
});