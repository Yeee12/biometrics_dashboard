
import 'package:flutter/material.dart';
import '../../../domain/entities/time_range.dart';
import '../../../core/constants/app_constants.dart';

class RangeSelector extends StatelessWidget {
  final TimeRange selectedRange;
  final Function(TimeRange) onRangeChanged;

  const RangeSelector({
    Key? key,
    required this.selectedRange,
    required this.onRangeChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: TimeRange.values.map((range) {
        final isSelected = range == selectedRange;
        return Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: ChoiceChip(
            label: Text(range.label),
            selected: isSelected,
            onSelected: (_) {
              onRangeChanged(range);
            },
            backgroundColor: AppConstants.surfaceDark,
            selectedColor: AppConstants.primaryAccent,
            labelStyle: TextStyle(
              color: isSelected
                  ? Colors.white
                  : AppConstants.textSecondary,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        );
      }).toList(),
    );
  }
}