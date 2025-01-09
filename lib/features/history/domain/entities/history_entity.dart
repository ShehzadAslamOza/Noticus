import 'dart:typed_data';

class HistoryEntity {
  final String id;
  final String appName;
  final String packageName;
  final String title;
  final String? subtitle;
  final DateTime timestamp;
  final Uint8List? appIcon;

  HistoryEntity({
    required this.id,
    required this.appName,
    required this.packageName,
    required this.title,
    this.subtitle,
    required this.timestamp,
    this.appIcon,
  });
}
