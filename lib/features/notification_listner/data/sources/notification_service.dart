import 'package:notification_listener_service/notification_event.dart';
import 'package:notification_listener_service/notification_listener_service.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  Stream<ServiceNotificationEvent> listenToNotifications() {
    return NotificationListenerService.notificationsStream;
  }

  Future<bool> requestPermission() async {
    return await NotificationListenerService.requestPermission();
  }

  Future<bool> isPermissionGranted() async {
    return await NotificationListenerService.isPermissionGranted();
  }
}
