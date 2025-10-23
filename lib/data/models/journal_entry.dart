import 'package:json_annotation/json_annotation.dart';
part 'journal_entry.g.dart';

@JsonSerializable()
class JournalEntry {
  final String date;

  final int mood;

  final String note;

  JournalEntry({
    required this.date,
    required this.mood,
    required this.note,
  });

  factory JournalEntry.fromJson(Map<String, dynamic> json) =>
      _$JournalEntryFromJson(json);

  Map<String, dynamic> toJson() => _$JournalEntryToJson(this);


  DateTime get dateTime => DateTime.parse(date);
}