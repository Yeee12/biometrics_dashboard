import 'package:json_annotation/json_annotation.dart';
part 'biometric_data.g.dart';

@JsonSerializable()
class BiometricData {
  final String date;
  final double? hrv;

  final int? rhr;

  final int? steps;

  final int? sleepScore;

  BiometricData({
    required this.date,
    this.hrv,
    this.rhr,
    this.steps,
    this.sleepScore,
  });

  factory BiometricData.fromJson(Map<String, dynamic> json) =>
      _$BiometricDataFromJson(json);

  Map<String, dynamic> toJson() => _$BiometricDataToJson(this);

  DateTime get dateTime => DateTime.parse(date);
  BiometricData copyWith({
    String? date,
    double? hrv,
    int? rhr,
    int? steps,
    int? sleepScore,
  }) {
    return BiometricData(
      date: date ?? this.date,
      hrv: hrv ?? this.hrv,
      rhr: rhr ?? this.rhr,
      steps: steps ?? this.steps,
      sleepScore: sleepScore ?? this.sleepScore,
    );
  }
}