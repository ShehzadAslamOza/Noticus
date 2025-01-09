import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:noticus/features/notification_listner/domain/usecases/start_notification_listner.dart';
import 'package:noticus/features/notification_listner/domain/usecases/stop_notification_listner.dart';
import 'package:notification_listener_service/notification_event.dart';

part 'notification_listner_event.dart';
part 'notification_listner_state.dart';

class NotificationListenerBloc
    extends Bloc<NotificationListenerEvent, NotificationListenerState> {
  final Stream<ServiceNotificationEvent> Function(String userId) startListener;
  final Future<void> Function() stopListener;

  NotificationListenerBloc({
    required this.startListener,
    required this.stopListener,
  }) : super(NotificationListenerInitial()) {
    on<StartListeningEvent>((event, emit) async {
      emit(NotificationListenerRunning());
      startListener(event.userId).listen((notification) {});
    });

    on<StopListeningEvent>((event, emit) async {
      await stopListener();
      emit(NotificationListenerStopped());
    });
  }
}
