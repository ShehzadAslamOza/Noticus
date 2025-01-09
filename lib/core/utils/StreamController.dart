import 'dart:async';

import 'package:noticus/features/notification_listner/domain/entities/notification_entity.dart';

class NotificationEventBus {
  static final NotificationEventBus _instance =
      NotificationEventBus._internal();
  factory NotificationEventBus() => _instance;
  NotificationEventBus._internal();

  final StreamController<NotificationEntity> _streamController =
      StreamController<NotificationEntity>.broadcast();

  Stream<NotificationEntity> get stream => _streamController.stream;

  void emit(NotificationEntity notification) {
    _streamController.add(notification);
  }

  void dispose() {
    _streamController.close();
  }
}
