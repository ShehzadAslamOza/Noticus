import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:installed_apps/app_info.dart';
import '../../domain/entities/history_entity.dart';

class HistoryRemoteDataSource {
  final FirebaseFirestore firestore;

  HistoryRemoteDataSource({required this.firestore});

  Future<List<HistoryEntity>> fetchHistory(String userId) async {
    final querySnapshot = await firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .get();

    final historyList = <HistoryEntity>[];

    for (var doc in querySnapshot.docs) {
      final data = doc.data();
      Uint8List? appIcon;
      String appName = '';

      try {
        // Fetch app info using the installed_app package
        final AppInfo? appInfo =
            await InstalledApps.getAppInfo(data['packageName']);
        appIcon = appInfo?.icon;
        appName = appInfo?.name ?? '';
      } catch (e) {
        // Handle cases where app info cannot be fetched
        appIcon = null;
      }

      historyList.add(
        HistoryEntity(
          id: doc.id,
          appName: appName ?? 'Unknown App',
          packageName: data['packageName'] ?? 'Unknown App',
          title: data['title'] ?? 'No Title',
          subtitle: data['content'],
          timestamp: DateTime.parse(data['timestamp']),
          appIcon: appIcon,
        ),
      );
    }

    return historyList;
  }
}
