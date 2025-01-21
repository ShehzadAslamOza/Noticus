part of 'rules_bloc.dart';

abstract class RulesState extends Equatable {
  @override
  List<Object?> get props => [];
}

class RulesInitial extends RulesState {}

class RulesLoaded extends RulesState {
  final String userId;
  final bool searchMode;
  final String searchQuery;

  RulesLoaded({
    required this.userId,
    required this.searchMode,
    required this.searchQuery,
  });

  RulesLoaded copyWith({
    String? userId,
    bool? searchMode,
    String? searchQuery,
  }) {
    return RulesLoaded(
      userId: userId ?? this.userId,
      searchMode: searchMode ?? this.searchMode,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props => [userId, searchMode, searchQuery];
}
