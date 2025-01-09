part of 'navigation_bloc.dart';

abstract class NavigationEvent extends Equatable {
  const NavigationEvent();

  @override
  List<Object?> get props => [];
}

class NavigationTabChanged extends NavigationEvent {
  final int newIndex;

  const NavigationTabChanged(this.newIndex);

  @override
  List<Object?> get props => [newIndex];
}
