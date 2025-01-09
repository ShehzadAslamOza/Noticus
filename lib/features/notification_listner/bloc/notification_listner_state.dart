part of 'notification_listner_bloc.dart';

abstract class NotificationListenerState extends Equatable {
  @override
  List<Object?> get props => [];
}

class NotificationListenerInitial extends NotificationListenerState {}

class NotificationListenerRunning extends NotificationListenerState {}

class NotificationListenerStopped extends NotificationListenerState {}
