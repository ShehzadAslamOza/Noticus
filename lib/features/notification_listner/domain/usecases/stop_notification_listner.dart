import '../repositories/notification_repository.dart';

class StopNotificationListener {
  final NotificationRepository repository;

  StopNotificationListener(this.repository);

  Future<void> call() async {
    await repository.stopNotificationListener();
  }
}
