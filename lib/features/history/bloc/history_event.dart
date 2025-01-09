part of 'history_bloc.dart';

abstract class HistoryEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchHistoryEvent extends HistoryEvent {
  final String userId;

  FetchHistoryEvent(this.userId);

  @override
  List<Object?> get props => [userId];
}

class FetchLocalHistoryEvent extends HistoryEvent {}

class AddNotificationEvent extends HistoryEvent {
  final NotificationEntity notification;

  AddNotificationEvent(this.notification);

  @override
  List<Object?> get props => [notification];
}
