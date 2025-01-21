part of 'history_bloc.dart';

abstract class HistoryState extends Equatable {
  @override
  List<Object?> get props => [];
}

class HistoryInitial extends HistoryState {}

class HistoryLoading extends HistoryState {}

class HistoryLoaded extends HistoryState {
  final List<HistoryEntity> history;
  final List<HistoryEntity> filteredHistory;
  final bool isSearching;
  final bool showDashboard;
  final String searchQuery;

  HistoryLoaded({
    required this.history,
    required this.filteredHistory,
    this.isSearching = false,
    this.showDashboard = false,
    this.searchQuery = '',
  });

  HistoryLoaded copyWith({
    List<HistoryEntity>? history,
    List<HistoryEntity>? filteredHistory,
    bool? isSearching,
    bool? showDashboard,
    String? searchQuery,
  }) {
    return HistoryLoaded(
      history: history ?? this.history,
      filteredHistory: filteredHistory ?? this.filteredHistory,
      isSearching: isSearching ?? this.isSearching,
      showDashboard: showDashboard ?? this.showDashboard,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props =>
      [history, filteredHistory, isSearching, showDashboard, searchQuery];
}

class HistoryError extends HistoryState {
  final String message;

  HistoryError(this.message);

  @override
  List<Object?> get props => [message];
}
