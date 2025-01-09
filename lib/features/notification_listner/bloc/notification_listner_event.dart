part of 'notification_listner_bloc.dart';

abstract class NotificationListenerEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class StartListeningEvent extends NotificationListenerEvent {
  final String userId;

  StartListeningEvent(this.userId);

  @override
  List<Object?> get props => [userId];
}

class StopListeningEvent extends NotificationListenerEvent {}
