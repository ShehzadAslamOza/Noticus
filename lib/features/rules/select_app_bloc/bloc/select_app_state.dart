part of 'select_app_bloc.dart';

abstract class SelectAppState extends Equatable {
  @override
  List<Object?> get props => [];
}

class SelectAppInitial extends SelectAppState {}

class AppsLoadingState extends SelectAppState {}

class AppsLoadedState extends SelectAppState {
  final List<AppInfo> apps;
  final List<AppInfo> filteredApps;

  AppsLoadedState({required this.apps, required this.filteredApps});

  AppsLoadedState copyWith({
    List<AppInfo>? apps,
    List<AppInfo>? filteredApps,
  }) {
    return AppsLoadedState(
      apps: apps ?? this.apps,
      filteredApps: filteredApps ?? this.filteredApps,
    );
  }

  @override
  List<Object?> get props => [apps, filteredApps];
}

class AppsErrorState extends SelectAppState {
  final String message;

  AppsErrorState({required this.message});

  @override
  List<Object?> get props => [message];
}
