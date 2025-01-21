part of 'rules_bloc.dart';

abstract class RulesEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadUserId extends RulesEvent {}

class ToggleSearchMode extends RulesEvent {}

class ExitSearchMode extends RulesEvent {}

class UpdateSearchQuery extends RulesEvent {
  final String query;

  UpdateSearchQuery(this.query);

  @override
  List<Object?> get props => [query];
}
