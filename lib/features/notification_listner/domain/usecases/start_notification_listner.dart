import 'package:notification_listener_service/notification_event.dart';
import '../repositories/notification_repository.dart';

class StartNotificationListener {
  final NotificationRepository repository;

  StartNotificationListener(this.repository);

  Stream<ServiceNotificationEvent> call(String userId) {
    return repository.startNotificationListener(userId);
  }
}
