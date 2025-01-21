import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:installed_apps/app_info.dart';

part 'select_app_event.dart';
part 'select_app_state.dart';

class SelectAppBloc extends Bloc<SelectAppEvent, SelectAppState> {
  final Future<List<AppInfo>> appsFuture;

  SelectAppBloc(this.appsFuture) : super(SelectAppInitial()) {
    on<LoadAppsEvent>((event, emit) async {
      emit(AppsLoadingState());
      try {
        final apps = await appsFuture;
        emit(AppsLoadedState(apps: apps, filteredApps: apps));
      } catch (e) {
        emit(AppsErrorState(message: 'Failed to load apps.'));
      }
    });

    on<FilterAppsEvent>((event, emit) {
      if (state is AppsLoadedState) {
        final loadedState = state as AppsLoadedState;
        final filteredApps = loadedState.apps
            .where((app) => app.name.toLowerCase().contains(event.query))
            .toList();
        emit(loadedState.copyWith(filteredApps: filteredApps));
      }
    });
  }
}
