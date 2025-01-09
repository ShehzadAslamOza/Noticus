import '../entities/notification_entity.dart';
import 'package:notification_listener_service/notification_event.dart';

abstract class NotificationRepository {
  Future<void> saveNotification(NotificationEntity notification);
  Stream<ServiceNotificationEvent> startNotificationListener(String userId);
  Future<void> stopNotificationListener();
}
