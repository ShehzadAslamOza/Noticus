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

class StartSearchEvent extends HistoryEvent {
  final List<HistoryEntity> history;
  StartSearchEvent(this.history);

  @override
  List<Object?> get props => [history];
}

class StopSearchEvent extends HistoryEvent {}

class SearchQueryChangedEvent extends HistoryEvent {
  final String query;
  final List<HistoryEntity> history;

  SearchQueryChangedEvent(this.query, this.history);

  @override
  List<Object?> get props => [query, history];
}

class ToggleDashboardEvent extends HistoryEvent {}

class ClearAllNotificationsEvent extends HistoryEvent {
  final String userId;
  ClearAllNotificationsEvent(this.userId);

  @override
  List<Object?> get props => [userId];
}

class DeleteNotificationEvent extends HistoryEvent {
  final String notificationId;

  DeleteNotificationEvent(this.notificationId);

  @override
  List<Object?> get props => [notificationId];
}
