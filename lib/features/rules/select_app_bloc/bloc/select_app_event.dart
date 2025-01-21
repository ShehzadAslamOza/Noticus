part of 'select_app_bloc.dart';

abstract class SelectAppEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadAppsEvent extends SelectAppEvent {}

class FilterAppsEvent extends SelectAppEvent {
  final String query;

  FilterAppsEvent(this.query);

  @override
  List<Object?> get props => [query];
}
