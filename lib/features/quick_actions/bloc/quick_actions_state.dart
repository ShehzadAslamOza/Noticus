part of 'quick_actions_bloc.dart';

sealed class QuickActionsState extends Equatable {
  const QuickActionsState();
  
  @override
  List<Object> get props => [];
}

final class QuickActionsInitial extends QuickActionsState {}
