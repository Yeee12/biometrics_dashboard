
import 'package:biometrics_dashboard/data/models/biometric_data.dart';
import 'package:biometrics_dashboard/presentation/widgets/states/error_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/biometric_provider.dart';
import '../widgets/charts/biometric_chart.dart';
import '../widgets/controls/range_selector.dart';
import '../widgets/states/loading_skeleton.dart';
import '../../core/constants/app_constants.dart';
import '../../data/services/data_decimator.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(biometricProvider);
    final notifier = ref.read(biometricProvider.notifier);

    return Scaffold(
      appBar: _buildAppBar(context, state, notifier),
      body: _buildBody(context, state, notifier),
    );
  }

  PreferredSizeWidget _buildAppBar(
      BuildContext context,
      BiometricState state,
      BiometricNotifier notifier,
      ) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return AppBar(
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.favorite, color: AppConstants.hrvColor, size: isSmallScreen ? 20 : 24),
          SizedBox(width: isSmallScreen ? 6 : 8),
          Flexible(
            child: Text(
              isSmallScreen ? 'Biometrics' : 'Biometrics Dashboard',
              style: TextStyle(fontSize: isSmallScreen ? 16 : 20),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(
            state.useLargeDataset ? Icons.speed : Icons.speed_outlined,
            color: state.useLargeDataset ? AppConstants.primaryAccent : null,
            size: isSmallScreen ? 20 : 24,
          ),
          onPressed: () => notifier.toggleLargeDataset(),
          tooltip: state.useLargeDataset ? 'Using 10k points' : 'Use large dataset',
        ),
      ],
    );
  }

  Widget _buildBody(
      BuildContext context,
      BiometricState state,
      BiometricNotifier notifier,
      ) {
    if (state.isLoading) {
      return LoadingSkeleton();
    }

    if (state.error != null) {
      return ErrorView(
        error: state.error!,
        onRetry: () => notifier.retry(),
        isRetrying: state.isRetrying,
      );
    }

    if (state.filteredData.isEmpty) {
      return _buildEmptyView();
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;
    final isMediumScreen = screenWidth >= 600 && screenWidth < 1024;

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(isSmallScreen ? 12.0 : 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(context, state, notifier, isSmallScreen),
            SizedBox(height: isSmallScreen ? 16 : 24),
            _buildSummaryCards(context, state, isSmallScreen, isMediumScreen),
            SizedBox(height: isSmallScreen ? 16 : 24),

            // HRV Chart
            BiometricChart(
              title: 'Heart Rate Variability (HRV)',
              data: notifier.getDecimatedHRV(),
              getValue: (d) => d.hrv,
              lineColor: AppConstants.hrvColor,
              hoveredDate: state.hoveredDate,
              onHover: (date) => notifier.setHoveredDate(date),
              unit: 'ms',
              showBands: true,
              journals: notifier.getFilteredJournals(),
            ),
            SizedBox(height: isSmallScreen ? 12 : 16),

            // RHR Chart
            BiometricChart(
              title: 'Resting Heart Rate (RHR)',
              data: notifier.getDecimatedRHR(),
              getValue: (d) => d.rhr?.toDouble(),
              lineColor: AppConstants.rhrColor,
              hoveredDate: state.hoveredDate,
              onHover: (date) => notifier.setHoveredDate(date),
              unit: 'bpm',
              journals: notifier.getFilteredJournals(),
            ),
            SizedBox(height: isSmallScreen ? 12 : 16),

            // Steps Chart
            BiometricChart(
              title: 'Daily Steps',
              data: notifier.getDecimatedSteps(),
              getValue: (d) => d.steps?.toDouble(),
              lineColor: AppConstants.stepsColor,
              hoveredDate: state.hoveredDate,
              onHover: (date) => notifier.setHoveredDate(date),
              unit: 'steps',
              journals: notifier.getFilteredJournals(),
            ),
            SizedBox(height: isSmallScreen ? 24 : 32),

            _buildPerformanceNote(state, isSmallScreen),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
      BuildContext context,
      BiometricState state,
      BiometricNotifier notifier,
      bool isSmallScreen,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isSmallScreen ? 'Health Metrics' : 'Health Metrics Overview',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
            fontSize: isSmallScreen ? 20 : 28,
          ),
        ),
        if (!isSmallScreen) ...[
          const SizedBox(height: 8),
          Text(
            'Synchronized time-series visualization with performance optimization',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
        SizedBox(height: isSmallScreen ? 12 : 16),

        RangeSelector(
          selectedRange: state.selectedRange,
          onRangeChanged: (range) {
            print('🔄 Switching to ${range.label}');
            notifier.switchRange(range);
          },
        ),
      ],
    );
  }

  Widget _buildSummaryCards(
      BuildContext context,
      BiometricState state,
      bool isSmallScreen,
      bool isMediumScreen,
      ) {
    final data = state.filteredData;

    final avgHrv = _calculateAverage(data, (d) => d.hrv);
    final avgRhr = _calculateAverage(data, (d) => d.rhr?.toDouble());
    final avgSteps = _calculateAverage(data, (d) => d.steps?.toDouble());

    // On small screens, stack cards vertically
    if (isSmallScreen) {
      return Column(
        children: [
          _SummaryCard(
            title: 'Avg HRV',
            value: avgHrv.toStringAsFixed(1),
            unit: 'ms',
            icon: Icons.favorite,
            color: AppConstants.hrvColor,
            isCompact: true,
          ),
          const SizedBox(height: 8),
          _SummaryCard(
            title: 'Avg RHR',
            value: avgRhr.toStringAsFixed(0),
            unit: 'bpm',
            icon: Icons.monitor_heart,
            color: AppConstants.rhrColor,
            isCompact: true,
          ),
          const SizedBox(height: 8),
          _SummaryCard(
            title: 'Avg Steps',
            value: (avgSteps / 1000).toStringAsFixed(1),
            unit: 'k',
            icon: Icons.directions_walk,
            color: AppConstants.stepsColor,
            isCompact: true,
          ),
        ],
      );
    }

    return Row(
      children: [
        Expanded(
          child: _SummaryCard(
            title: 'Avg HRV',
            value: avgHrv.toStringAsFixed(1),
            unit: 'ms',
            icon: Icons.favorite,
            color: AppConstants.hrvColor,
            isCompact: false,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _SummaryCard(
            title: 'Avg RHR',
            value: avgRhr.toStringAsFixed(0),
            unit: 'bpm',
            icon: Icons.monitor_heart,
            color: AppConstants.rhrColor,
            isCompact: false,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _SummaryCard(
            title: 'Avg Steps',
            value: (avgSteps / 1000).toStringAsFixed(1),
            unit: 'k',
            icon: Icons.directions_walk,
            color: AppConstants.stepsColor,
            isCompact: false,
          ),
        ),
      ],
    );
  }

  double _calculateAverage(
      List<BiometricData> data,
      double? Function(BiometricData) getValue,
      ) {
    final values = data
        .map(getValue)
        .where((v) => v != null)
        .cast<double>()
        .toList();

    if (values.isEmpty) return 0;
    return values.reduce((a, b) => a + b) / values.length;
  }

  Widget _buildPerformanceNote(BiometricState state, bool isSmallScreen) {
    final dataLength = state.filteredData.length;
    final isDecimated = DataDecimator.shouldDecimate(dataLength);

    return Card(
      color: AppConstants.surfaceDark.withOpacity(0.5),
      child: Padding(
        padding: EdgeInsets.all(isSmallScreen ? 12.0 : 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.speed,
                  size: isSmallScreen ? 18 : 20,
                  color: AppConstants.primaryAccent,
                ),
                SizedBox(width: isSmallScreen ? 6 : 8),
                Text(
                  'Performance Note',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppConstants.textPrimary,
                    fontSize: isSmallScreen ? 13 : 14,
                  ),
                ),
              ],
            ),
            SizedBox(height: isSmallScreen ? 6 : 8),
            Text(
              'Dataset: ${state.useLargeDataset ? "Large (10k+ points)" : "Normal (90 days)"}',
              style: TextStyle(
                color: AppConstants.textSecondary,
                fontSize: isSmallScreen ? 12 : 13,
              ),
            ),
            Text(
              'Filtered points: $dataLength',
              style: TextStyle(
                color: AppConstants.textSecondary,
                fontSize: isSmallScreen ? 12 : 13,
              ),
            ),
            if (isDecimated) ...[
              SizedBox(height: isSmallScreen ? 3 : 4),
              Text(
                '✓ LTTB decimation applied → ${AppConstants.decimationThreshold} points',
                style: TextStyle(
                  color: AppConstants.primaryAccent,
                  fontWeight: FontWeight.w500,
                  fontSize: isSmallScreen ? 11 : 12,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.insert_chart_outlined,
            size: 64,
            color: AppConstants.textSecondary,
          ),
          const SizedBox(height: 16),
          Text(
            'No data available',
            style: TextStyle(
              fontSize: 20,
              color: AppConstants.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final String unit;
  final IconData icon;
  final Color color;
  final bool isCompact;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.unit,
    required this.icon,
    required this.color,
    required this.isCompact,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(isCompact ? 12.0 : 16.0),
        child: isCompact
            ? _buildCompactLayout(context)
            : _buildNormalLayout(context),
      ),
    );
  }

  Widget _buildCompactLayout(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    unit,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNormalLayout(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              unit,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ],
    );
  }
}
