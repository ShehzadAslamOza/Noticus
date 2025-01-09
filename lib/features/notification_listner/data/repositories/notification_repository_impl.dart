import 'dart:async';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:noticus/core/utils/StreamController.dart';
import 'package:notification_listener_service/notification_event.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/repositories/notification_repository.dart';
import '../sources/notification_service.dart';
import 'package:torch_controller/torch_controller.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final FirebaseFirestore firestore;
  final NotificationService notificationService;

  StreamSubscription<ServiceNotificationEvent>?
      _subscription; // Manage subscription

  NotificationRepositoryImpl({
    required this.firestore,
    required this.notificationService,
  });

  @override
  Future<void> saveNotification(NotificationEntity notification) async {
    await firestore.collection('notifications').add(notification.toMap());
  }

  @override
  Stream<ServiceNotificationEvent> startNotificationListener(
      String userId) async* {
    // Cancel any existing subscription
    await _subscription?.cancel();

    final stream = notificationService.listenToNotifications();

    _subscription = stream.listen((event) async {
      log("Received notification: ${event.title}");

      final notification = NotificationEntity(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: userId,
        packageName: event.packageName ?? '',
        title: event.title ?? '',
        content: event.content ?? '',
        timestamp: DateTime.now(),
      );

      saveNotification(notification);

      NotificationEventBus().emit(notification);

      // Fetch rules for the current user
      final querySnapshot = await firestore
          .collection('rules')
          .where('userId', isEqualTo: userId)
          .get();

      for (var doc in querySnapshot.docs) {
        final data = doc.data();

        if (data['isActive'] == true) {
          if (data['packageName'] == event.packageName) {
            log("Matching rule found: ${data['description']}");

            if (data['action'] == "Ring") {
              FlutterRingtonePlayer().playAlarm();
              Future.delayed(Duration(seconds: 10), () {
                FlutterRingtonePlayer().stop();
              });
            }

            if (data['action'] == "Open") {
              InstalledApps.startApp(data['packageName']);
            }

            if (data['action'] == "Pin") {
              print("Pin");
            }

            if (data['action'] == "Torch") {
              for (int i = 0; i < 5; i++) {
                // Turn torch on/off
                await Future.delayed(Duration(milliseconds: 2000),
                    () => TorchController().toggle()); // Delay between toggles
              }

              // Ensure the torch is turned off at the end
              if (await TorchController().isTorchActive ?? false) {
                await TorchController().toggle();
              }
            }

            break;
          }
        }
      }
    });

    yield* stream;
  }

  @override

  /// Cancels the subscription to the notification listener service.
  ///
  /// This is typically called when the user navigates away from the screen
  /// that is listening to notifications.
  Future<void> stopNotificationListener() async {
    // Cancel the subscription
    await _subscription?.cancel();
    log("Notification listener stopped");
  }
}
