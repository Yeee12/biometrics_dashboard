
import 'package:biometrics_dashboard/presentation/widgets/states/error_view.dart';
import 'package:biometrics_dashboard/presentation/widgets/states/loading_skeleton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:biometrics_dashboard/presentation/screens/dashboard_screen.dart';
import 'package:biometrics_dashboard/presentation/providers/biometric_provider.dart';
import 'package:biometrics_dashboard/data/models/biometric_data.dart';
import 'package:biometrics_dashboard/data/models/journal_entry.dart';
import 'package:biometrics_dashboard/data/repositories/biometric_repository.dart';
import 'package:biometrics_dashboard/data/repositories/journal_repository.dart';
import 'package:biometrics_dashboard/domain/entities/time_range.dart';

void main() {
  group('Dashboard Widget Tests', () {
    late List<BiometricData> mockData;
    late List<JournalEntry> mockJournals;

    setUp(() {

      mockData = List.generate(
        90,
            (i) => BiometricData(
          date: DateTime(2025, 7, 24)
              .add(Duration(days: i))
              .toIso8601String()
              .split('T')[0],
          hrv: 55.0 + (i % 15).toDouble(),
          rhr: 58 + (i % 8),
          steps: 6000 + (i * 50),
          sleepScore: 70 + (i % 20),
        ),
      );

      mockJournals = [
        JournalEntry(date: '2025-09-25', mood: 2, note: 'Bad sleep'),
        JournalEntry(date: '2025-10-05', mood: 5, note: 'Great run!'),
        JournalEntry(date: '2025-10-15', mood: 4, note: 'Feeling strong'),
      ];
    });

    testWidgets('displays loading skeleton initially', (tester) async {
      final container = ProviderContainer(
        overrides: [
          biometricProvider.overrideWith((ref) {
            return BiometricNotifier(
              SlowMockBiometricRepository(mockData),
              SlowMockJournalRepository(mockJournals),
            );
          }),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: DashboardScreen()),
        ),
      );

      expect(find.byType(LoadingSkeleton), findsOneWidget);
      await tester.pumpAndSettle();
      expect(find.byType(LoadingSkeleton), findsNothing);
      expect(find.text('Heart Rate Variability (HRV)'), findsOneWidget);

      container.dispose();
    });

    testWidgets('range switch updates all charts', (tester) async {
      final container = ProviderContainer(
        overrides: [
          biometricProvider.overrideWith((ref) {
            return BiometricNotifier(
              MockBiometricRepository(mockData),
              MockJournalRepository(mockJournals),
            );
          }),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: DashboardScreen()),
        ),
      );

      await tester.pumpAndSettle();

      final state30d = container.read(biometricProvider);
      expect(state30d.selectedRange, equals(TimeRange.days30));
      expect(state30d.filteredData.length, equals(30));

      await tester.tap(find.text('7d'));
      await tester.pumpAndSettle();

      final state7d = container.read(biometricProvider);
      expect(state7d.selectedRange, equals(TimeRange.days7));
      expect(state7d.filteredData.length, equals(7));

      await tester.tap(find.text('90d'));
      await tester.pumpAndSettle();

      final state90d = container.read(biometricProvider);
      expect(state90d.selectedRange, equals(TimeRange.days90));
      expect(state90d.filteredData.length, equals(90));

      container.dispose();
    });

    testWidgets('tooltip synchronization across charts', (tester) async {
      final container = ProviderContainer(
        overrides: [
          biometricProvider.overrideWith((ref) {
            return BiometricNotifier(
              MockBiometricRepository(mockData),
              MockJournalRepository(mockJournals),
            );
          }),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: DashboardScreen()),
        ),
      );

      await tester.pumpAndSettle();


      expect(container.read(biometricProvider).hoveredDate, isNull);


      container.read(biometricProvider.notifier).setHoveredDate('2025-08-01');
      await tester.pump();

      expect(container.read(biometricProvider).hoveredDate, equals('2025-08-01'));


      container.read(biometricProvider.notifier).setHoveredDate(null);
      await tester.pump();


      expect(container.read(biometricProvider).hoveredDate, isNull);

      container.dispose();
    });

    testWidgets('error view shows retry button', (tester) async {
      final container = ProviderContainer(
        overrides: [
          biometricProvider.overrideWith((ref) {
            return BiometricNotifier(
              FailingMockBiometricRepository(),
              FailingMockJournalRepository(),
            );
          }),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: DashboardScreen()),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(ErrorView), findsOneWidget);
      expect(find.text('Try Again'), findsOneWidget);


      container.dispose();
    });

    testWidgets('displays three charts when data loaded', (tester) async {
      final container = ProviderContainer(
        overrides: [
          biometricProvider.overrideWith((ref) {
            return BiometricNotifier(
              MockBiometricRepository(mockData),
              MockJournalRepository(mockJournals),
            );
          }),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: DashboardScreen()),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Heart Rate Variability (HRV)'), findsOneWidget);
      expect(find.text('Resting Heart Rate (RHR)'), findsOneWidget);
      expect(find.text('Daily Steps'), findsOneWidget);

      container.dispose();
    });

    testWidgets('displays journal markers on charts', (tester) async {
      final container = ProviderContainer(
        overrides: [
          biometricProvider.overrideWith((ref) {
            return BiometricNotifier(
              MockBiometricRepository(mockData),
              MockJournalRepository(mockJournals),
            );
          }),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: DashboardScreen()),
        ),
      );

      await tester.pumpAndSettle();

      final state = container.read(biometricProvider);
      expect(state.journals.length, equals(3));

      final filteredJournals = container
          .read(biometricProvider.notifier)
          .getFilteredJournals();

      expect(filteredJournals.length, greaterThanOrEqualTo(1));

      container.dispose();
    });
  });
}


class MockBiometricRepository extends BiometricRepository {
  final List<BiometricData> mockData;
  MockBiometricRepository(this.mockData);

  @override
  Future<List<BiometricData>> loadBiometrics() async {
    return mockData;
  }

  @override
  Future<List<BiometricData>> loadLargeDataset() async {
    return mockData;
  }
}

class MockJournalRepository extends JournalRepository {
  final List<JournalEntry> mockJournals;
  MockJournalRepository(this.mockJournals);

  @override
  Future<List<JournalEntry>> loadJournals() async {
    return mockJournals;
  }
}

class SlowMockBiometricRepository extends BiometricRepository {
  final List<BiometricData> mockData;
  SlowMockBiometricRepository(this.mockData);

  @override
  Future<List<BiometricData>> loadBiometrics() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return mockData;
  }

  @override
  Future<List<BiometricData>> loadLargeDataset() async {
    return mockData;
  }
}

class SlowMockJournalRepository extends JournalRepository {
  final List<JournalEntry> mockJournals;
  SlowMockJournalRepository(this.mockJournals);

  @override
  Future<List<JournalEntry>> loadJournals() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return mockJournals;
  }
}

class FailingMockBiometricRepository extends BiometricRepository {
  @override
  Future<List<BiometricData>> loadBiometrics() async {
    await Future.delayed(const Duration(milliseconds: 10));
    throw Exception('Simulated failure');
  }

  @override
  Future<List<BiometricData>> loadLargeDataset() async {
    throw Exception('Simulated failure');
  }
}

class FailingMockJournalRepository extends JournalRepository {
  @override
  Future<List<JournalEntry>> loadJournals() async {
    await Future.delayed(const Duration(milliseconds: 10));
    throw Exception('Simulated failure');
  }
}