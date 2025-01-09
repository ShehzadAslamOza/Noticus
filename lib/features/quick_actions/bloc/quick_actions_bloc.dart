import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'quick_actions_event.dart';
part 'quick_actions_state.dart';

class QuickActionsBloc extends Bloc<QuickActionsEvent, QuickActionsState> {
  QuickActionsBloc() : super(QuickActionsInitial()) {
    on<QuickActionsEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
