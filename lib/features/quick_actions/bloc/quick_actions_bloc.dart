import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_dnd/flutter_dnd.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dnd/flutter_dnd.dart';
import 'package:volume_controller/volume_controller.dart';

part 'quick_actions_event.dart';
part 'quick_actions_state.dart';

class QuickActionsBloc extends Bloc<QuickActionsEvent, QuickActionsState> {
  final VolumeController _volumeController = VolumeController.instance;

  QuickActionsBloc()
      : super(const QuickActionsState(
          isDndEnabled: false,
          isNotificationPolicyAccessGranted: false,
          volumeValue: 0.0,
        )) {
    on<FetchInitialDataEvent>(_fetchInitialData);
    on<ToggleDndEvent>(_toggleDnd);
    on<UpdateVolumeEvent>(_updateVolume);
    on<InitializeMockStateEvent>(_initializeMockState); // New handler
  }

  Future<void> _fetchInitialData(
      FetchInitialDataEvent event, Emitter<QuickActionsState> emit) async {
    bool isAccessGranted =
        await FlutterDnd.isNotificationPolicyAccessGranted ?? false;

    double initialVolume = await _volumeController.getVolume();

    if (isAccessGranted) {
      int? filter = await FlutterDnd.getCurrentInterruptionFilter();
      emit(state.copyWith(
        isNotificationPolicyAccessGranted: true,
        isDndEnabled: filter == FlutterDnd.INTERRUPTION_FILTER_NONE,
        volumeValue: initialVolume,
      ));
    } else {
      emit(state.copyWith(
        isNotificationPolicyAccessGranted: false,
        isDndEnabled: false,
        volumeValue: initialVolume,
      ));
    }
  }

  Future<void> _toggleDnd(
      ToggleDndEvent event, Emitter<QuickActionsState> emit) async {
    if (state.isNotificationPolicyAccessGranted) {
      if (event.enable) {
        await FlutterDnd.setInterruptionFilter(
            FlutterDnd.INTERRUPTION_FILTER_NONE);
      } else {
        await FlutterDnd.setInterruptionFilter(
            FlutterDnd.INTERRUPTION_FILTER_ALL);
      }
      emit(state.copyWith(isDndEnabled: event.enable));
    } else {
      FlutterDnd.gotoPolicySettings();
    }
  }

  Future<void> _updateVolume(
      UpdateVolumeEvent event, Emitter<QuickActionsState> emit) async {
    _volumeController.setVolume(event.volume);
    emit(state.copyWith(volumeValue: event.volume));
  }

  Future<void> _initializeMockState(
      InitializeMockStateEvent event, Emitter<QuickActionsState> emit) async {
    emit(event.mockState); // Directly emit the mock state
  }
}


// class QuickActionsBloc extends Bloc<QuickActionsEvent, QuickActionsState> {
//   final VolumeController _volumeController = VolumeController.instance;

//   QuickActionsBloc()
//       : super(const QuickActionsState(
//           isDndEnabled: false,
//           isNotificationPolicyAccessGranted: false,
//           volumeValue: 0.0,
//         )) {
//     on<FetchInitialDataEvent>(_fetchInitialData);
//     on<ToggleDndEvent>(_toggleDnd);
//     on<UpdateVolumeEvent>(_updateVolume);
//   }

//   Future<void> _fetchInitialData(
//       FetchInitialDataEvent event, Emitter<QuickActionsState> emit) async {
//     bool isAccessGranted =
//         await FlutterDnd.isNotificationPolicyAccessGranted ?? false;

//     double initialVolume = await _volumeController.getVolume();

//     if (isAccessGranted) {
//       int? filter = await FlutterDnd.getCurrentInterruptionFilter();
//       emit(state.copyWith(
//         isNotificationPolicyAccessGranted: true,
//         isDndEnabled: filter == FlutterDnd.INTERRUPTION_FILTER_NONE,
//         volumeValue: initialVolume,
//       ));
//     } else {
//       emit(state.copyWith(
//         isNotificationPolicyAccessGranted: false,
//         isDndEnabled: false,
//         volumeValue: initialVolume,
//       ));
//     }
//   }

//   Future<void> _toggleDnd(
//       ToggleDndEvent event, Emitter<QuickActionsState> emit) async {
//     if (state.isNotificationPolicyAccessGranted) {
//       if (event.enable) {
//         await FlutterDnd.setInterruptionFilter(
//             FlutterDnd.INTERRUPTION_FILTER_NONE);
//       } else {
//         await FlutterDnd.setInterruptionFilter(
//             FlutterDnd.INTERRUPTION_FILTER_ALL);
//       }
//       emit(state.copyWith(isDndEnabled: event.enable));
//     } else {
//       FlutterDnd.gotoPolicySettings();
//     }
//   }

//   Future<void> _updateVolume(
//       UpdateVolumeEvent event, Emitter<QuickActionsState> emit) async {
//     _volumeController.setVolume(event.volume);
//     emit(state.copyWith(volumeValue: event.volume));
//   }
// }
