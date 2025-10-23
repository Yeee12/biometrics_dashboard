import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../data/models/biometric_data.dart';
import '../../../data/models/journal_entry.dart';
import '../../../core/constants/app_constants.dart';

class BiometricChart extends StatelessWidget {
  final String title;
  final List<BiometricData> data;
  final double? Function(BiometricData) getValue;
  final Color lineColor;
  final String? hoveredDate;
  final Function(String?) onHover;
  final String unit;
  final bool showBands;
  final List<JournalEntry> journals;

  const BiometricChart({
    Key? key,
    required this.title,
    required this.data,
    required this.getValue,
    required this.lineColor,
    required this.onHover,
    this.hoveredDate,
    this.unit = '',
    this.showBands = false,
    this.journals = const [],
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;


    if (journals.isNotEmpty) {
      for (var j in journals) {
      }
      if (data.isNotEmpty) {
      }
    }

    if (data.isEmpty) {
      return _buildEmptyState();
    }

    final spots = _createSpots();
    final (minY, maxY) = _calculateYRange(spots);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.chartPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (journals.isNotEmpty) ...[
                        const Icon(
                          Icons.edit_note,
                          size: 16,
                          color: AppConstants.annotationColor,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            '${journals.length} ${journals.length == 1 ? 'entry' : 'entries'}',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppConstants.annotationColor,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 16),
                      ],
                      Text(
                        '${spots.length} points',
                        style: Theme.of(context).textTheme.bodyMedium,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),


            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppConstants.primaryAccent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppConstants.primaryAccent.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.touch_app,
                    size: 14,
                    color: AppConstants.primaryAccent,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Pinch to zoom • Drag to pan',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppConstants.textSecondary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),

            // Chart
            SizedBox(
              height: AppConstants.chartHeight,
              child: InteractiveViewer(
                boundaryMargin: const EdgeInsets.all(20),
                minScale: 0.5,
                maxScale: 4.0,
                constrained: false,
                child: SizedBox(
                  width: MediaQuery.of(context).size.width - 32,
                  height: AppConstants.chartHeight,
                  child: LineChart(
                    LineChartData(
                      lineBarsData: [
                        LineChartBarData(
                          spots: spots,
                          isCurved: true,
                          color: lineColor,
                          barWidth: 2,
                          dotData: const FlDotData(show: false),
                          belowBarData: BarAreaData(
                            show: true,
                            color: lineColor.withOpacity(0.1),
                          ),
                        ),
                      ],
                      extraLinesData: _buildExtraLines(spots,),
                      lineTouchData: _buildTouchData(context),
                      titlesData: _buildTitles(context),
                      gridData: _buildGrid(),
                      borderData: _buildBorder(),
                      minY: minY,
                      maxY: maxY,
                      minX: 0,
                      maxX: (data.length - 1).toDouble(),
                    ),
                  ),
                ),
              ),
            ),

            if (journals.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildJournalLegend(context, isSmallScreen),
            ],
          ],
        ),
      ),
    );
  }


  Widget _buildTitleRow(BuildContext context, bool isSmallScreen, List<FlSpot> spots) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontSize: isSmallScreen ? 16 : 18,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (journals.isNotEmpty) ...[
                Icon(
                  Icons.edit_note,
                  size: isSmallScreen ? 14 : 16,
                  color: AppConstants.annotationColor,
                ),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    '${journals.length} ${journals.length == 1 ? 'entry' : 'entries'}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppConstants.annotationColor,
                      fontSize: isSmallScreen ? 11 : 13,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(width: isSmallScreen ? 8 : 16),
              ],
              Text(
                '${spots.length} pts',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: isSmallScreen ? 11 : 13,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }


  Widget _buildPanZoomInstruction() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppConstants.primaryAccent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppConstants.primaryAccent.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.touch_app,
            size: 14,
            color: AppConstants.primaryAccent,
          ),
          SizedBox(width: 6),
          Text(
            'Pinch to zoom • Drag to pan',
            style: TextStyle(
              fontSize: 11,
              color: AppConstants.textSecondary,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  List<FlSpot> _createSpots() {
    final spots = <FlSpot>[];
    for (int i = 0; i < data.length; i++) {
      final value = getValue(data[i]);
      if (value != null) {
        spots.add(FlSpot(i.toDouble(), value));
      }
    }
    return spots;
  }

  (double, double) _calculateYRange(List<FlSpot> spots) {
    if (spots.isEmpty) return (0, 100);

    final values = spots.map((s) => s.y).toList();
    final min = values.reduce((a, b) => a < b ? a : b);
    final max = values.reduce((a, b) => a > b ? a : b);

    final range = max - min;
    final padding = range * 0.1;

    return (min - padding, max + padding);
  }

  ExtraLinesData _buildExtraLines(List<FlSpot> spots) {
    final verticalLines = <VerticalLine>[];
    final horizontalLines = <HorizontalLine>[];
    if (showBands && spots.length >= 7) {
      final mean = _calculateRollingMean(spots, 7);
      final stdDev = _calculateStdDev(spots, mean);

      horizontalLines.addAll([
        HorizontalLine(
          y: mean + stdDev,
          color: lineColor.withOpacity(0.3),
          strokeWidth: 1,
          dashArray: [5, 5],
        ),
        HorizontalLine(
          y: mean,
          color: lineColor.withOpacity(0.5),
          strokeWidth: 1,
        ),
        HorizontalLine(
          y: mean - stdDev,
          color: lineColor.withOpacity(0.3),
          strokeWidth: 1,
          dashArray: [5, 5],
        ),
      ]);
    }

    if (hoveredDate != null) {
      final hoveredIndex = _findDateIndex(hoveredDate!);
      if (hoveredIndex != -1) {
        verticalLines.add(
          VerticalLine(
            x: hoveredIndex.toDouble(),
            color: AppConstants.primaryAccent,
            strokeWidth: 2,
            dashArray: [5, 5],
          ),
        );
      }
    }

    for (final journal in journals) {
      final index = _findDateIndex(journal.date);

      if (index != -1) {
        verticalLines.add(
          VerticalLine(
            x: index.toDouble(),
            color: AppConstants.annotationColor,
            strokeWidth: 2,
            dashArray: [8, 4],
            label: VerticalLineLabel(
              show: true,
              alignment: Alignment.topCenter,
              padding: EdgeInsets.zero,
              style: const TextStyle(
                fontSize: 28,
                height: 1.0,
                backgroundColor: Colors.transparent,
              ),
              labelResolver: (line) => _getMoodEmoji(journal.mood),
            ),
          ),
        );
      } else {
        print('⚠️ Journal date ${journal.date} not found in chart data');
      }
    }

    print('📍 Added ${verticalLines.length} markers to $title (crosshair + ${journals.length} journals)');

    return ExtraLinesData(
      verticalLines: verticalLines,
      horizontalLines: horizontalLines,
    );
  }

  int _findDateIndex(String date) {
    return data.indexWhere((d) => d.date == date);
  }

  String _getMoodEmoji(int mood) {
    switch (mood) {
      case 1:
        return '😢';
      case 2:
        return '😕';
      case 3:
        return '😐';
      case 4:
        return '😊';
      case 5:
        return '😄';
      default:
        return '📝';
    }
  }

  Widget _buildJournalLegend(BuildContext context, bool isSmallScreen) {
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: journals.map((journal) {
        return GestureDetector(
          onTap: () => _showJournalDialog(context, journal),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppConstants.annotationColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppConstants.annotationColor.withOpacity(0.5),
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _getMoodEmoji(journal.mood),
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(width: 6),
                Text(
                  DateFormat('MMM d').format(journal.dateTime),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppConstants.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }


  void _showJournalDialog(BuildContext context, JournalEntry journal) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppConstants.surfaceDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Text(_getMoodEmoji(journal.mood), style: const TextStyle(fontSize: 36)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DateFormat('MMMM d, yyyy').format(journal.dateTime),
                    style: const TextStyle(
                      color: AppConstants.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Mood: ${journal.mood}/5',
                    style: const TextStyle(
                      color: AppConstants.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        content: Text(
          journal.note,
          style: const TextStyle(
            color: AppConstants.textPrimary,
            fontSize: 16,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Close',
              style: TextStyle(color: AppConstants.primaryAccent),
            ),
          ),
        ],
      ),
    );
  }

  double _calculateRollingMean(List<FlSpot> spots, int window) {
    if (spots.isEmpty) return 0;
    final recentSpots = spots.length > window
        ? spots.sublist(spots.length - window)
        : spots;
    final sum = recentSpots.fold(0.0, (sum, spot) => sum + spot.y);
    return sum / recentSpots.length;
  }

  double _calculateStdDev(List<FlSpot> spots, double mean) {
    if (spots.isEmpty) return 0;
    final variance = spots.fold(
      0.0,
          (sum, spot) => sum + (spot.y - mean) * (spot.y - mean),
    ) / spots.length;
    return variance.isNaN ? 0 : sqrt(variance);
  }

  LineTouchData _buildTouchData(BuildContext context) {
    return LineTouchData(
      enabled: true,
      handleBuiltInTouches: true,
      touchCallback: (event, response) {
        if (event is FlTapUpEvent || event is FlPanUpdateEvent) {
          if (response?.lineBarSpots?.isNotEmpty ?? false) {
            final index = response!.lineBarSpots!.first.x.toInt();
            if (index >= 0 && index < data.length) {
              onHover(data[index].date);
            }
          }
        } else if (event is FlPanEndEvent || event is FlTapCancelEvent) {
          onHover(null);
        }
      },
      touchTooltipData: LineTouchTooltipData(
        tooltipBgColor: AppConstants.surfaceDark,
        tooltipBorder: BorderSide(
          color: AppConstants.textSecondary.withOpacity(0.3),
        ),
        tooltipRoundedRadius: 8,
        getTooltipItems: (spots) {
          return spots.map((spot) {
            final index = spot.x.toInt();
            if (index < 0 || index >= data.length) return null;

            final date = data[index].date;
            final value = spot.y.toStringAsFixed(1);

            final journal = journals.where((j) => j.date == date).firstOrNull;

            return LineTooltipItem(
              journal != null
                  ? '$date\n$value $unit\n${_getMoodEmoji(journal.mood)} ${journal.note}'
                  : '$date\n$value $unit',
              const TextStyle(
                color: AppConstants.textPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            );
          }).toList();
        },
      ),
    );
  }

  FlTitlesData _buildTitles(BuildContext context) {
    return FlTitlesData(
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          interval: _calculateDateInterval(),
          getTitlesWidget: (value, meta) {
            final index = value.toInt();
            if (index < 0 || index >= data.length) return const SizedBox();

            final interval = _calculateDateInterval().round();
            final showLabel = index == 0 ||
                index == data.length - 1 ||
                index % interval == 0;

            if (!showLabel) return const SizedBox();

            final date = DateTime.tryParse(data[index].date);
            if (date == null) return const SizedBox();

            return Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                DateFormat('MMM d').format(date),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 10,
                  color: AppConstants.textSecondary,
                ),
              ),
            );
          },
        ),
      ),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 45,
          getTitlesWidget: (value, meta) {
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Text(
                value.toStringAsFixed(0),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            );
          },
        ),
      ),
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    );
  }


  double _calculateDateInterval() {
    if (data.isEmpty) return 1;
    if (data.length <= 7) return 1;
    if (data.length <= 14) return 2;
    if (data.length <= 30) return 5;
    if (data.length <= 60) return 10;
    if (data.length <= 90) return 15;
    return (data.length / 8).floorToDouble();
  }


  FlGridData _buildGrid() {
    return FlGridData(
      show: true,
      drawVerticalLine: false,
      horizontalInterval: null,
      getDrawingHorizontalLine: (value) {
        return FlLine(
          color: AppConstants.textSecondary.withOpacity(0.1),
          strokeWidth: 1,
        );
      },
    );
  }

  FlBorderData _buildBorder() {
    return FlBorderData(
      show: true,
      border: Border(
        bottom: BorderSide(
          color: AppConstants.textSecondary.withOpacity(0.3),
          width: 1,
        ),
        left: BorderSide(
          color: AppConstants.textSecondary.withOpacity(0.3),
          width: 1,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Card(
      child: Container(
        height: AppConstants.chartHeight + 60,
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.insert_chart_outlined,
                size: 48,
                color: AppConstants.textSecondary,
              ),
              SizedBox(height: 16),
              Text(
                'No data available',
                style: TextStyle(color: AppConstants.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}