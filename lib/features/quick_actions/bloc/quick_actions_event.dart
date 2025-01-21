part of 'quick_actions_bloc.dart';

abstract class QuickActionsEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class ToggleDndEvent extends QuickActionsEvent {
  final bool enable;

  ToggleDndEvent(this.enable);

  @override
  List<Object?> get props => [enable];
}

class UpdateVolumeEvent extends QuickActionsEvent {
  final double volume;

  UpdateVolumeEvent(this.volume);

  @override
  List<Object?> get props => [volume];
}

class FetchInitialDataEvent extends QuickActionsEvent {}

class InitializeMockStateEvent extends QuickActionsEvent {
  final QuickActionsState mockState;

  InitializeMockStateEvent(this.mockState);

  @override
  List<Object?> get props => [mockState];
}
