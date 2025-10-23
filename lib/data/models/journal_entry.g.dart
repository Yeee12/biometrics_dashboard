// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'journal_entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

JournalEntry _$JournalEntryFromJson(Map<String, dynamic> json) => JournalEntry(
  date: json['date'] as String,
  mood: (json['mood'] as num).toInt(),
  note: json['note'] as String,
);

Map<String, dynamic> _$JournalEntryToJson(JournalEntry instance) =>
    <String, dynamic>{
      'date': instance.date,
      'mood': instance.mood,
      'note': instance.note,
    };
