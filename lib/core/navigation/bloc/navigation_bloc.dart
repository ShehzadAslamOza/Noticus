import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';

part 'navigation_event.dart';
part 'navigation_state.dart';

class NavigationBloc extends Bloc<NavigationEvent, NavigationState> {
  NavigationBloc() : super(const NavigationState(currentIndex: 0)) {
    on<NavigationTabChanged>((event, emit) {
      emit(NavigationState(currentIndex: event.newIndex));
    });
  }
}
